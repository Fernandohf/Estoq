import 'package:estoq/data.dart';
import 'package:estoq/main.dart';
import 'package:flutter/material.dart';
import 'navigation.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Estoq',
      home: Scaffold(
          drawer: DrawerHome(),
          appBar: AppBar(
            title: Text(
              'Estoq',
              style: TextStyle(fontSize: 25),
            ),
            backgroundColor: Colors.blueAccent,
          ),
          body: SessionsBuilder(),
          floatingActionButton: ActionButton()),
    );
  }
}

class DrawerHome extends StatelessWidget {
  const DrawerHome({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
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
                      navigateToSettings(context);
                      // Update the state of the app.
                      // ...
                    },
                  ),
                  ListTile(
                      leading: Icon(Icons.restore),
                      title: Text('Resetar'),
                      onTap: () {
                        Sessions data = Home.of(context).sessions;
                        data.deleteAll();
                      }),
                  ListTile(
                    leading: Icon(Icons.arrow_upward),
                    title: Text('Exportar'),
                    onTap: () async {
                      // Update the state of the app.
                      // ...
                      Sessions sessions = Home.of(context).sessions;
                      UserSettings settings = Home.of(context).settings;
                      SnackBar snackExport = SnackBar(content: Text("${sessions.data.length} sessões foram exportadas"));
                      await sessions.exportAll(settings.delimiter);
                      Navigator.of(context).pop();
                      Scaffold.of(context).showSnackBar(snackExport);
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
    );
  }
}

class SessionsBuilder extends StatefulWidget {
  @override
  _SessionsBuilderState createState() => _SessionsBuilderState();
}

class _SessionsBuilderState extends State<SessionsBuilder> {
  Sessions sessions;
  @override
  Widget build(BuildContext context) {
    sessions = Home.of(context).sessions;
    if (this.sessions.data.isEmpty) {
      return Center(
          child: Text(
        "Nada aqui... 🙃",
        style: TextStyle(fontSize: 20, color: Colors.grey[500]),
      ));
    } else {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            SessionTileItem(sessions.data.values.toList()[index]),
        itemCount: sessions.data.values.length,
      );
    }
  }
}

class SessionTileItem extends StatefulWidget {
  final SessionData sessionData;
  final Key key = UniqueKey();
  SessionTileItem(this.sessionData);

  @override
  _SessionTileItemState createState() =>
      _SessionTileItemState(this.sessionData);
}

class _SessionTileItemState extends State<SessionTileItem> {
  final SessionData sessionData;
  _SessionTileItemState(this.sessionData);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: sessionData.name,
      child: Padding(
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
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 24,
                            fontWeight: FontWeight.w600),
                      ),
                      Container(
                        child: Text(
                          sessionData.entries.isEmpty
                              ? "Nada aqui..."
                              : sessionData.entries[0].toString() + "\n" + "...",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colors.blueGrey[300], fontSize: 12),
                        ),
                      )
                    ]),
              ),
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
  @override
  _NewSessionDialogState createState() => _NewSessionDialogState();
}

class _NewSessionDialogState extends State<NewSessionDialog> {
  final formController = TextEditingController();
  @override
  void dispose() {
    formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Sessions sessions = Home.of(context).sessions;
    formController.text = "Sessão_${sessions.data.length + 1}";
    return SimpleDialog(
        title: Text("Nova Sessão"),
        contentPadding: EdgeInsets.all(8),
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: Container(
                child: Form(
                  child: TextFormField(
                    controller: formController,
                    decoration: InputDecoration(
                        hintText: "Nome da Sessão",
                        border: OutlineInputBorder(
                          gapPadding: 3,
                        )),
                  ),
                ),
              )),
          ButtonBar(
            alignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar',
                      style: TextStyle(color: Colors.redAccent))),
              FlatButton(
                  onPressed: () async {
                    Sessions sessions = Home.of(context).sessions;
                    // Create session
                    SessionData newSession =
                        new SessionData.empty(formController.text);
                    // check if name is duplicated
                    if (sessions.data.keys
                        .contains(newSession.key.toString())) {
                      showDialog(
                        context: context,
                        builder: (_) => new AlertDialog(
                          title: Text(
                            "Nome duplicado!",
                          
                          ),
                          contentPadding: EdgeInsets.zero,
                          actions: <Widget>[
                            FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("OK")),
                          ],
                        ),
                      );
                    } else {
                      Navigator.pop(context);

                      sessions.add(newSession);
                      navigateToActiveSession(context, newSession);
                    }
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
