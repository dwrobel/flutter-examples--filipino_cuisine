import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;

import 'cook.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class MyHttpClient implements HttpClient {
  HttpClient _realClient;

  MyHttpClient(this._realClient) {
    _realClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      print('badCertificateCallback cert:$cert, host:$host, port:$port');
      return true;
    };
  }

  @override
  bool get autoUncompress => _realClient.autoUncompress;

  @override
  set autoUncompress(bool value) => _realClient.autoUncompress = value;

  @override
  Duration get connectionTimeout => _realClient.connectionTimeout;

  @override
  set connectionTimeout(Duration value) =>
      _realClient.connectionTimeout = value;

  @override
  Duration get idleTimeout => _realClient.idleTimeout;

  @override
  set idleTimeout(Duration value) => _realClient.idleTimeout = value;

  @override
  int get maxConnectionsPerHost => _realClient.maxConnectionsPerHost;

  @override
  set maxConnectionsPerHost(int value) =>
      _realClient.maxConnectionsPerHost = value;

  @override
  String get userAgent => _realClient.userAgent;

  @override
  set userAgent(String value) => _realClient.userAgent = value;

  @override
  void addCredentials(
          Uri url, String realm, HttpClientCredentials credentials) =>
      _realClient.addCredentials(url, realm, credentials);

  @override
  void addProxyCredentials(String host, int port, String realm,
          HttpClientCredentials credentials) =>
      _realClient.addProxyCredentials(host, port, realm, credentials);

  @override
  void set authenticate(
          Future<bool> Function(Uri url, String scheme, String realm) f) =>
      _realClient.authenticate = f;

  @override
  void set authenticateProxy(
          Future<bool> Function(
                  String host, int port, String scheme, String realm)
              f) =>
      _realClient.authenticateProxy = f;

  @override
  void set badCertificateCallback(
          bool Function(X509Certificate cert, String host, int port)
              callback) =>
      _realClient.badCertificateCallback = callback;

  @override
  void close({bool force = false}) => _realClient.close(force: force);

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      _realClient.delete(host, port, path);

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => _realClient.deleteUrl(url);

  @override
  void set findProxy(String Function(Uri url) f) => _realClient.findProxy = f;

  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      _updateHeaders(_realClient.get(host, port, path));

  Future<HttpClientRequest> _updateHeaders(
      Future<HttpClientRequest> httpClientRequest) async {
    return (await httpClientRequest)..headers.add('foo', 'bar');
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      _updateHeaders(_realClient.getUrl(url.replace(path: url.path)));

  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      _realClient.head(host, port, path);

  @override
  Future<HttpClientRequest> headUrl(Uri url) => _realClient.headUrl(url);

  @override
  Future<HttpClientRequest> open(
          String method, String host, int port, String path) =>
      _realClient.open(method, host, port, path);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      _realClient.openUrl(method, url);

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      _realClient.patch(host, port, path);

  @override
  Future<HttpClientRequest> patchUrl(Uri url) => _realClient.patchUrl(url);

  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      _realClient.post(host, port, path);

  @override
  Future<HttpClientRequest> postUrl(Uri url) => _realClient.postUrl(url);

  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      _realClient.put(host, port, path);

  @override
  Future<HttpClientRequest> putUrl(Uri url) => _realClient.putUrl(url);
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return new MyHttpClient(super.createHttpClient(context));
  }
}

void main() {
  // See https://github.com/flutter/flutter/wiki/Desktop-shells#target-platform-override
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  HttpOverrides.global = new MyHttpOverrides();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(ct) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.light,accentColor: Colors.red,iconTheme: IconThemeData(color: Colors.red)),
      title: "Filipino Cuisine",
      home: Home());
  }
}

class Home extends StatefulWidget {
  HState createState() => HState();
}

class HState extends State<Home> {
  List fd;
  Map fi;

  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    http.Response r = await http.get('https://filipino-cuisine-app.firebaseio.com/data.json');
    fd = json.decode(r.body);
    setState(() => fi = fd[0]);
  }

  Widget build(ct) {
    if (fd == null) return Container(color: Colors.white,child: Center(child: CircularProgressIndicator(),));
    var t = Theme.of(ct).textTheme;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 5,
            child: Swiper(
                onIndexChanged: (n) => setState(() => fi = fd[n]),
                itemCount: fd.length,
                itemBuilder: (cx, i) {
                  return Container(margin: EdgeInsets.only(top: 40, bottom: 24),
                      child: ClipRRect( borderRadius: BorderRadius.circular(20),
                        child: Hero(tag: fd[i]['fn'], child: Image.asset('assets/' + fd[i]['pf'],fit: BoxFit.cover)),));
                  },
                viewportFraction: .85,scale: .9)
          ),
          Text(fi['fn'],style:t.display3.copyWith(fontFamily: 'ark', color: Colors.black)),
          Container(
            child: Text(fi['cn'],style: t.subhead.apply(color: Colors.red, fontFamily: 'opb')),
            margin: EdgeInsets.only(top: 10, bottom: 30),
          ),
          Container(
              child: Text(fi['dc'],textAlign: TextAlign.center,style: t.subhead.copyWith(fontFamily: 'opr')),
              margin: EdgeInsets.only(left: 10, right: 10)),
          Expanded(flex: 2,
            child: ListView.builder(scrollDirection: Axis.horizontal,itemCount: fi['ig'].length,
              itemBuilder: (cx, i) {
                return Row(
                  children: <Widget>[
                    Container(margin: EdgeInsets.only(left: 10),height: 60,
                      child: Image.asset('assets/' + fi['ig'][i]['p'],fit: BoxFit.contain)),
                    Container(margin: EdgeInsets.only(left: 5, right: 10),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(fi['ig'][i]['n'],style: t.subtitle.copyWith(fontFamily: 'opb')),
                          Text(fi['ig'][i]['c'],style: t.caption.copyWith(fontFamily: 'opr'))]))]);
              }))
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(child: Icon(Icons.restaurant_menu),
        onPressed: () => Navigator.push(ct, MaterialPageRoute(builder: (cx) => Cook(fi['in'], fi['pf'], fi['fn']))),
      ),
      bottomNavigationBar: BottomAppBar(shape: CircularNotchedRectangle(),notchMargin: 4.0,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(icon: Icon(fi['fv'] ? Icons.favorite : Icons.favorite_border),onPressed: () => setState(() => fi['fv'] = !fi['fv'])),
            IconButton(icon: Icon(Icons.share),onPressed: () {})
          ])),
    );
  }
}
