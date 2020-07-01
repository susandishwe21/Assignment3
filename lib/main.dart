import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: NowPlayingHome(),
    routes: {DetailsNowPlaying.routeName: (context) => DetailsNowPlaying()},
  ));
}

class NowPlaying {
  final String title;
  final String posterPath;
  final String overview;
  final String releaseDate;
  final num voteAverage;

  NowPlaying(
      {this.title,
      this.posterPath,
      this.overview,
      this.releaseDate,
      this.voteAverage});
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NowPlayingHome(),
    );
  }
}

class NowPlayingHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NowPlayingState();
  }
}

class _NowPlayingState extends State<NowPlayingHome> {
  var baseUrl = 'https://image.tmdb.org/t/p/w500/';

  Future<List<NowPlaying>> getNowPlaying() async {
    var data = await http.get(
        'https://api.themoviedb.org/3/movie/now_playing?api_key=492d89b92b96921e521f24bfe0a61d86');

    var jsonData = json.decode(data.body);
    var nowPlayingData = jsonData['results'];

    List<NowPlaying> nowplaying = [];

    for (var data in nowPlayingData) {
      NowPlaying nowPlayingItem = NowPlaying(
          title: data['title'],
          posterPath: data['poster_path'],
          overview: data['overview'],
          releaseDate: data['release_date'],
          voteAverage: data['vote_average']);
      nowplaying.add(nowPlayingItem);
    }
    return nowplaying;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Now Playing List'),
      ),
      body: Container(
        child: FutureBuilder(
            future: getNowPlaying(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return GridView.count(
                  crossAxisCount: 2,
                  children: List.generate(snapshot.data.length, (index) {
                    return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, DetailsNowPlaying.routeName,
                              arguments: snapshot.data[index]);
                        },
                        child: _buildListItem(context, index, snapshot));
                  }),
                );
              }
            }),
      ),
    );
  }

  Widget _buildListItem(
      BuildContext context, int index, AsyncSnapshot snapshot) {
    return Card(
        child: Column(
      children: [
        Container(
            child: ClipRRect(
          borderRadius: BorderRadius.all(const Radius.circular(8.0)),
          child: (snapshot.data[index].posterPath == null
              ? Image.network(
                  'https://www.bbc.co.uk/news/special/2015/newsspec_10857/bbc_news_logo.png?cb=1')
              : Image.network(
                  '$baseUrl${snapshot.data[index].posterPath}',
                  width: 150,
                  height: 150,
                  fit: BoxFit.fill,
                )),
        )),
        Align(
            alignment: Alignment.center,
            child: Container(
                child: Text(
              snapshot.data[index].title,
              textAlign: TextAlign.center,
            ))),
      ],
    ));
  }
}

class DetailsNowPlaying extends StatelessWidget {
  static const routeName = '/extractArgument';

  @override
  Widget build(BuildContext context) {
    final NowPlaying args = ModalRoute.of(context).settings.arguments;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Details of Now Playing'),
        ),
        body: Center(
          child: SingleChildScrollView(
              child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    margin: EdgeInsets.all(15.0),
                     padding: EdgeInsets.all(0),
                    child: Image.network(
                        "https://image.tmdb.org/t/p/w500/" + args.posterPath,
                        height: 200,
                        width: 300,
                        fit: BoxFit.fill),
                  ),
                  AppBar(
                    backgroundColor: Colors.transparent,
                    leading: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios),
                    ),
                    elevation: 0,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      args.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                          wordSpacing: 0.6),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Release Date :" + args.releaseDate,
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "Vote Average :" + args.voteAverage.toString(),
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                args.overview,
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12.0,
                    letterSpacing: 0.2,
                    wordSpacing: 0.6),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
