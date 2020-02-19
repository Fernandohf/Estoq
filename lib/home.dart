import 'package:estoq/data.dart';
import 'package:flutter/material.dart';
import 'navigation.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Estoq',
      home: Scaffold(
          drawer: Drawer(
            child: SafeArea(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                          Text(
                            'Total de coletas:',
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[100]),
                          ),
                        ]),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Configurações'),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.arrow_upward),
                    title: Text('Exportar'),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text('Informações'),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                    },
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            title: Text(
              'Estoq',
              style: TextStyle(fontSize: 25),
            ),
            backgroundColor: Colors.blueAccent,
          ),
          body: _buildSessions(),
          floatingActionButton: ActionButton()),
    );
  }
}


Widget _buildSessions() {
  List<SessionData> data = loadSessionsData();
  if (data.isEmpty) {
    return Center(
        child: Text(
      "Nada aqui... 🙃",
      style: TextStyle(fontSize: 20, color: Colors.grey[500]),
    ));
  } else {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) =>
          SessionTileItem(data[index]),
      itemCount: data.length,
    );
  }
}

class SessionTileItem extends StatelessWidget {
  final SessionData sessionData;
  SessionTileItem(this.sessionData);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(.5),
      child: Card(
        color: Colors.blueGrey[50],
        child: InkWell(
          onTap: () {
            navigateToSession(context, sessionData);
          },
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      sessionData.name,
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.blueGrey, fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    Container(
                      child: Text(
                        sessionData.entries.isEmpty
                            ? "Nada aqui..."
                            : sessionData.entries[0].toString() + "\n" + "...",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.blueGrey[400], fontSize: 12),
                      ),
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(context: context, builder: (_) => new NewSessionDialog());
        // showDialog(context: context, builder: (_) => new NewSessionDialog());
      },
      backgroundColor: Colors.blueAccent,
      child: const Icon(Icons.add),
      tooltip: 'Nova sessão de coleta',
    );
  }
}

class NewSessionDialog extends StatefulWidget {
  NewSessionDialog({Key key}) : super(key: key);

  @override
  _NewSessionDialogState createState() => _NewSessionDialogState();
}

class _NewSessionDialogState extends State<NewSessionDialog> {
  final formController = TextEditingController(text: "Nome da sessão");
  @override
  void dispose() {
    formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(title: Text("Nova Sessão"), children: <Widget>[
      Padding(
          padding: const EdgeInsets.fromLTRB(18, 1, 18, 2),
          child: Container(
            child: Form(
              child: TextFormField(
                controller: formController,
                decoration: InputDecoration(
                    hintText: "Nome da Sessão",
                    border: OutlineInputBorder(
                      gapPadding: .3,
                    )),
              ),
            ),
          )),
      ButtonBar(
        alignment: MainAxisAlignment.end,
        children: <Widget>[
          FlatButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text('Cancelar', style: TextStyle(color: Colors.redAccent))),
          FlatButton(
              onPressed: () {
                Navigator.pop(context);
                SessionData newSession =
                    new SessionData.empty(name: formController.text);
                navigateToActiveSession(context, newSession);
              },
              child: Text(
                'Iniciar',
                style: TextStyle(color: Colors.blueAccent),
              )),
        ],
      )
    ]);
  }
}
