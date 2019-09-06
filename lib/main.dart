import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram',
      theme: ThemeData(
        primaryColor: Colors.black,
        primaryIconTheme: IconThemeData(color: Colors.black),
        primaryTextTheme: TextTheme(title: TextStyle(color: Colors.black, fontFamily: "Aveny")),
        textTheme: TextTheme(title: TextStyle(color: Colors.black))
      ),
      home: MyHomePage(),
    );
  }
}

///CommentsPage//////////////////////////////////////////////////////////////////////////////////////////////////////////

class CommentsPage extends StatefulWidget{
  List<dynamic> comments;
  List<dynamic> users;
  var tkn;
  var postId;

  CommentsPage(this.comments, this.users, this.tkn, this.postId);
  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {

  var controller1 = TextEditingController();

  void stuff(context) async {
    var allPosts = await getPosts(widget.tkn);
    var myPosts = await getAdminPosts(widget.tkn);
    Navigator.push(context, MaterialPageRoute(builder: (context) => SecondScreen(allPosts, myPosts, widget.tkn)));
  }

  Future<List<dynamic>> getAdminPosts(token) async {
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/my_posts";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader:"Bearer $token"});
    var posts_json = jsonDecode(response.body);
    return posts_json;
  }

  Future<List<dynamic>> getPosts(token) async {
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader:"Bearer $token"});
    var posts_json = jsonDecode(response.body);
    return posts_json;
  }  
  
  Future<void> postComment(var token, var pstId, var txt) async {
      var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$pstId/comments?text=$txt";
      var response = await http.post(url, headers: {HttpHeaders.authorizationHeader:"Bearer $token"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments', style: TextStyle(color: Colors.white),),
        leading:
        IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: (){
            // Navigator.pop(context);
            stuff(context);
          }
        )
      ),
      body: 
      ListView.builder(
        itemCount: widget.comments.length,
        itemBuilder: (BuildContext context, int index){
          String comment = widget.comments[index]["text"];
          String userEmail = widget.users[index]["email"];
          return
          Container(
            
            child: Column(
            children:[
            Text("$userEmail: $comment", style:TextStyle(fontSize: 18)),
            SizedBox(height: 20)
            ],
          ));
        }
      ),
      bottomNavigationBar: BottomAppBar(
        child:TextField(
        controller: controller1,
        decoration: InputDecoration(
          hintText: " Add a Comment",
          suffix: IconButton(icon: Icon(Icons.add_circle_outline),
          iconSize: 30, 
          onPressed:(){
            postComment(widget.tkn,widget.postId , controller1.text);
            setState((){
              widget.comments.add({"text": controller1.text});
              widget.users.add({"email":"reynaldo.deleo01@utrgv.edu"});
            });
          })
        ),
      )),
    );
  }
}

//UserPage//////////////////////////////////////////////////////////////////////////////////////////////////////

class UserPage extends StatefulWidget{
  List<dynamic> posts;
  var tkn;

  UserPage(this.posts, this.tkn);
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

Future<void> likePost(var token, var id) async {
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$id/likes";
    var response = await http.post(url, headers: {HttpHeaders.authorizationHeader:"Bearer $token"});
}

Future<void> unlike(var token, var id) async {
  var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$id/likes";
  var response = await http.delete(url, headers: {HttpHeaders.authorizationHeader:"Bearer $token"});
}

Future<List<dynamic>> getComments(var token, var id) async {
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$id/comments";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader:"Bearer $token"});
    var comments_json = jsonDecode(response.body);
    return comments_json;
}

Future<List<dynamic>> getUsers(var token, List<dynamic>comments) async
{
    List<dynamic> userList = new List<dynamic>();
    for(int i = 0; i < comments.length; i++)
    {
        var userNum = comments[i]["user_id"];
        var url = "https://serene-beach-48273.herokuapp.com/api/v1/users/$userNum";
        var response = await http.get(url, headers: {HttpHeaders.authorizationHeader:"Bearer $token"});
        var userInfoJson = jsonDecode(response.body);
        userList.add(userInfoJson);
    }
    return userList;
}

void openCommentsPage(var id, context) async
{
  var comments = await getComments(widget.tkn, id);
  var users = await getUsers(widget.tkn, comments);
  Navigator.push(context, MaterialPageRoute(builder: (context) => CommentsPage(comments, users, widget.tkn, id)));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      onPressed: (){
        Navigator.pop(context);
      },
      child: Icon(Icons.arrow_back_ios)
      ),
      body: ListView.builder(
              itemCount: widget.posts.length,
              itemBuilder: (BuildContext context, int index) {
                var userId = widget.posts[index]["user_id"];
                String titleOfPost = widget.posts[index]["caption"];
                var postImage = widget.posts[index]["image_url"];
                var profileImage = widget.posts[index]["user_profile_image_url"];
                String numLikes = widget.posts[index]["likes_count"].toString();
                String numComments = widget.posts[index]["comments_count"].toString();
                String user = widget.posts[index]["user_email"];
                var id = widget.posts[index]["id"];
                var likeStatus = widget.posts[index]["liked"];
                var created = widget.posts[index]["created_at"];
                return 
                Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children:[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0,0,0,0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(children: <Widget>[
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage(profileImage),
                                      fit: BoxFit.fill
                                    ),
                                  )
                                ),
                                SizedBox(width: 10),
                                Text(user, style:TextStyle(fontWeight: FontWeight.bold))
                              ]
                            ),
                            IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: null,
                            )
                          ],
                          )
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Image.network(postImage, fit: BoxFit.cover)
                        ),
                        
                        //3rd Row
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  IconButton(
                                    icon: likeStatus ? Icon(FontAwesomeIcons.solidHeart) : Icon(FontAwesomeIcons.heart),
                                    onPressed:(){
                                      if(likeStatus == false)
                                      {
                                        likePost(widget.tkn,id);
                                        setState(()
                                        {
                                          widget.posts[index]["liked"] = true;
                                          widget.posts[index]["likes_count"]++;
                                        });
                                      }
                                      else if(likeStatus == true)
                                      {
                                        unlike(widget.tkn, id);
                                        setState(()
                                        {
                                          widget.posts[index]["liked"] = false;
                                          widget.posts[index]["likes_count"]--;
                                        });
                                      }
                                    }
                                  ),
                                  SizedBox(width: 8,),
                                  IconButton(icon: Icon(FontAwesomeIcons.comment), onPressed: (){ openCommentsPage(id, context); }),
                                  SizedBox(width: 16,),
                                  Icon(FontAwesomeIcons.paperPlane)
                                ],
                              ),
                              Icon(FontAwesomeIcons.bookmark)
                            ],
                          )
                        ),
                        
                        //4th Row
                        SizedBox(height:10),
                        Text(" "+titleOfPost, style:TextStyle(fontSize: 18, color: Colors.black)),
                        SizedBox(height:10),
                        Text(created, style:TextStyle(fontSize: 15, color: Colors.grey)),
                        SizedBox(height:10),
                        Text(" Likes: " + numLikes, style:TextStyle(fontSize: 15, color: Colors.black)),
                        Text(" Comments: " + numComments, style:TextStyle(fontSize: 15, color: Colors.black))
                      ],
                    ),
                  padding:EdgeInsets.fromLTRB(0, 15, 0, 15)
              );
              },
            ),
    );
  }
}

//////SecondScreen///////////////////////////////////////////////////////////////////////////////////////////////////////

class SecondScreen extends StatefulWidget{
  List<dynamic> posts;
  List<dynamic> my_posts;
  var tokn;
  SecondScreen(var allPosts, var myPosts, var myToken) {
    posts = allPosts;
    my_posts = myPosts;
    tokn = myToken;
  }
  @override
  _SecondScreenState createState() => _SecondScreenState();

}


class _SecondScreenState extends State<SecondScreen> {

var captionController = TextEditingController();

  void stuff(context) async {
    var allPosts = await getPosts(widget.tokn);
    var myPosts = await getAdminPosts(widget.tokn);
    Navigator.push(context, MaterialPageRoute(builder: (context) => SecondScreen(allPosts, myPosts, widget.tokn)));
  }

Future<List<dynamic>> getPosts(token) async {
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader:"Bearer $token"});
    var posts_json = jsonDecode(response.body);
    return posts_json;
}

Future<List<dynamic>> getAdminPosts(token) async {
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/my_posts";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader:"Bearer $token"});
    var posts_json = jsonDecode(response.body);
    return posts_json;
}

Future<void> likePost(var token, var id) async {
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$id/likes";
    var response = await http.post(url, headers: {HttpHeaders.authorizationHeader:"Bearer $token"});
}

Future<void> unlike(var token, var id) async {
  var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$id/likes";
  var response = await http.delete(url, headers: {HttpHeaders.authorizationHeader:"Bearer $token"});
}

Future<List<dynamic>> getComments(var token, var id) async {
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/$id/comments";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader:"Bearer $token"});
    var comments_json = jsonDecode(response.body);
    return comments_json;
}

Future<List<dynamic>> getUsers(var token, List<dynamic>comments) async
{
    List<dynamic> userList = new List<dynamic>();
    for(int i = 0; i < comments.length; i++)
    {
        var userNum = comments[i]["user_id"];
        var url = "https://serene-beach-48273.herokuapp.com/api/v1/users/$userNum";
        var response = await http.get(url, headers: {HttpHeaders.authorizationHeader:"Bearer $token"});
        var userInfoJson = jsonDecode(response.body);
        userList.add(userInfoJson);
    }
    return userList;
}

void openCommentsPage(var id, context) async
{
  var comments = await getComments(widget.tokn, id);
  var users = await getUsers(widget.tokn, comments);
  Navigator.push(context, MaterialPageRoute(builder: (context) => CommentsPage(comments, users, widget.tokn, id)));
}

Future<List<dynamic>> getSpecificUserPosts(var token, var usrId) async {
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/users/$usrId/posts";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader:"Bearer $token"});
    var posts_json = jsonDecode(response.body);
    return posts_json;
}

void openUserPage(var userNum, context) async {
  var posts = await getSpecificUserPosts(widget.tokn, userNum);
  Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage(posts, widget.tokn)));
}

File image;
Future addImage() async{
  var img = await ImagePicker.pickImage(source: ImageSource.gallery);
  setState(() {
    image = img;
  });
}

void makePost(String caption, var token) {
  Dio dio = new Dio();
  FormData formdata = new FormData(); 
  formdata.add("image", new UploadFileInfo(image, basename(image.path)));
  formdata.add("caption", caption);
  dio.post("https://serene-beach-48273.herokuapp.com/api/v1/posts", data: formdata, options: Options(
  method: 'POST',
  responseType: ResponseType.json,
  headers: {HttpHeaders.authorizationHeader:"Bearer $token"}
  ))
  .then((response) => print(response))
  .catchError((error) => print(error));
}

  @override
  Widget build(BuildContext context) {
    var count = widget.posts.length;
    
    final topBar = AppBar(
    backgroundColor: Color(0xfff8faf8),
    centerTitle: true,
    elevation: 1.0,
    leading: IconButton(
      icon: Icon(Icons.camera_alt),
      onPressed: (){},
    ),
    actions: <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(Icons.send)
      )
    ],
    title: SizedBox(
      height: 35.0, child: Image.asset("assets/images/insta_logo.png")
    ),
    bottom: TabBar(
              labelColor: Colors.black,
              tabs: [Tab(icon: Icon(Icons.person)), Tab(icon: Icon(Icons.people)), Tab(icon: Icon(Icons.add_a_photo))])
  );

    return 
    DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: topBar,
        body: TabBarView(
          children:[
            
            //my_posts/////////////////////////////////////////////////////////////////////////////////////////
            RefreshIndicator(
              onRefresh:(){
                stuff(context);
              },
              child: ListView.builder(
              itemCount: widget.my_posts.length,
              itemBuilder: (BuildContext context, int index) {
                String user = widget.my_posts[index]["user_email"];
                var profileImage = widget.my_posts[index]["user_profile_image_url"];
                var created = widget.my_posts[index]["created_at"];
                String titleOfPost = widget.my_posts[index]["caption"];
                var postImage = widget.my_posts[index]["image_url"];
                String numLikes = widget.my_posts[index]["likes_count"].toString();
                String numComments = widget.my_posts[index]["comments_count"].toString();
                var id = widget.my_posts[index]["id"];
                var likeStatus = widget.my_posts[index]["liked"];
                return
                Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children:[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0,0,0,0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(children: <Widget>[
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage(profileImage),
                                      fit: BoxFit.fill
                                    ),
                                  )
                                ),
                                SizedBox(width: 10),
                                Text(user, style:TextStyle(fontWeight: FontWeight.bold))
                              ]
                            ),
                            IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: null,
                            )
                          ],
                          )
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Image.network(postImage, fit: BoxFit.cover)
                        ),
                        
                        //3rd Row
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  IconButton(
                                    icon: likeStatus ? Icon(FontAwesomeIcons.solidHeart) : Icon(FontAwesomeIcons.heart),
                                    onPressed:(){
                                      if(likeStatus == false)
                                      {
                                        likePost(widget.tokn,id);
                                        setState(()
                                        {
                                          widget.my_posts[index]["liked"] = true;
                                          widget.my_posts[index]["likes_count"]++;
                                        });
                                      }
                                      else if(likeStatus == true)
                                      {
                                        unlike(widget.tokn, id);
                                        setState(()
                                        {
                                          widget.my_posts[index]["liked"] = false;
                                          widget.my_posts[index]["likes_count"]--;
                                        });
                                      }
                                    }
                                  ),
                                  SizedBox(width: 8,),
                                  IconButton(icon: Icon(FontAwesomeIcons.comment), onPressed: (){ openCommentsPage(id, context); }),
                                  SizedBox(width: 16,),
                                  Icon(FontAwesomeIcons.paperPlane)
                                ],
                              ),
                              Icon(FontAwesomeIcons.bookmark)
                            ],
                          )
                        ),
                        
                        //4th Row
                        SizedBox(height:10),
                        Text(" "+titleOfPost, style:TextStyle(fontSize: 18, color: Colors.black)),
                        SizedBox(height:20),
                        Text(created, style:TextStyle(fontSize: 15, color: Colors.grey)),
                        SizedBox(height:10),
                        Text(" " + numLikes + " likes", style:TextStyle(fontSize: 15, color: Colors.black)),
                        SizedBox(height:10),
                        InkWell(
                          child: Text(" View all " + numComments + " comments", style:TextStyle(fontSize: 15, color: Colors.black)),
                          onTap:(){
                            openCommentsPage(id, context);
                          }
                        )
                      ],
                    ),
                  padding: EdgeInsets.fromLTRB(0, 30, 0, 30)
              );
            },
            )
            ),
            
            //all posts///////////////////////////////////////////////////////////////////////////////////
            RefreshIndicator(
              onRefresh:(){
                stuff(context);
              } ,
              child: ListView.builder(
              itemCount: widget.posts.length,
              itemBuilder: (BuildContext context, int index) {
                var userId = widget.posts[index]["user_id"];
                String titleOfPost = widget.posts[index]["caption"];
                var postImage = widget.posts[index]["image_url"];
                var profileImage = widget.posts[index]["user_profile_image_url"];
                String numLikes = widget.posts[index]["likes_count"].toString();
                String numComments = widget.posts[index]["comments_count"].toString();
                String user = widget.posts[index]["user_email"];
                var id = widget.posts[index]["id"];
                var likeStatus = widget.posts[index]["liked"];
                var created = widget.posts[index]["created_at"];
                return 
                Container(
                  child: 
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children:[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0,0,0,0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(children: <Widget>[
                                GestureDetector(
                                  onTap: (){openUserPage(userId, context);},
                                  child:Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage(profileImage),
                                      fit: BoxFit.fill
                                    ),
                                  )
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(user, style:TextStyle(fontWeight: FontWeight.bold))
                              ]
                            ),
                            IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: null,
                            )
                          ],
                          )
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Image.network(postImage, fit: BoxFit.cover)
                        ),
                        
                        //3rd Row
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  IconButton(
                                    icon: likeStatus ? Icon(FontAwesomeIcons.solidHeart) : Icon(FontAwesomeIcons.heart),
                                    onPressed:(){
                                      if(likeStatus == false)
                                      {
                                        likePost(widget.tokn,id);
                                        setState(()
                                        {
                                          widget.posts[index]["liked"] = true;
                                          widget.posts[index]["likes_count"]++;
                                        });
                                      }
                                      else if(likeStatus == true)
                                      {
                                        unlike(widget.tokn, id);
                                        setState(()
                                        {
                                          widget.posts[index]["liked"] = false;
                                          widget.posts[index]["likes_count"]--;
                                        });
                                      }
                                    }
                                  ),
                                  SizedBox(width: 8,),
                                  IconButton(icon: Icon(FontAwesomeIcons.comment), onPressed: (){ openCommentsPage(id, context); }),
                                  SizedBox(width: 16,),
                                  Icon(FontAwesomeIcons.paperPlane)
                                ],
                              ),
                              Icon(FontAwesomeIcons.bookmark)
                            ],
                          )
                        ),
                        
                        //4th Row
                        SizedBox(height:10),
                        Text(" "+titleOfPost, style:TextStyle(fontSize: 18, color: Colors.black)),
                        SizedBox(height:20),
                        Text(created, style:TextStyle(fontSize: 15, color: Colors.grey)),
                        SizedBox(height:10),
                        Text(" " + numLikes + " likes", style:TextStyle(fontSize: 15, color: Colors.black)),
                        SizedBox(height:10),
                        InkWell(
                          child: Text(" View all " + numComments + " comments", style:TextStyle(fontSize: 15, color: Colors.black)),
                          onTap:(){
                            openCommentsPage(id, context);
                          }
                        )
                        
                      ],
                    ),
                  padding:EdgeInsets.fromLTRB(0, 30, 0, 30)
              );
              },
              ),
            ),

            ////adding a post///////////////////////////////////////////////////////////////////////////
            
            Scaffold(
              body:Column(children: <Widget>[
                image == null ? Container() : Container(
                                                height: 450,
                                                width: 450,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  image: DecorationImage(
                                                    image: FileImage(image),
                                                    fit: BoxFit.fill
                                                  )
                                                )),
                FlatButton(
                textColor: Colors.white,
                color: Colors.black,
                child:Text("ADD PHOTO"),  
                onPressed: (){
                  addImage();
                }),
              ]),
              bottomNavigationBar: BottomAppBar(
                child:TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: " Add a Caption",
                  suffix: IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    iconSize: 30, 
                    onPressed:(){
                      makePost(captionController.text, widget.tokn);
                  })
                ),
              ))
            )
          ],
        ),
      ),
    );
  }
}

///MyHomePage/////////////////////////////////////////////////////////////////////////////////////////////////////////////

class MyHomePage extends StatelessWidget {
  var userCtrl = TextEditingController();
  var passCtrl = TextEditingController();

  void stuff(context) async {
    var token = await login();
    var allPosts = await getPosts(token);
    var myPosts = await getAdminPosts(token);
    Navigator.push(context, MaterialPageRoute(builder: (context) => SecondScreen(allPosts, myPosts, token)));
  }

  Future<String> login() async {
    var user = userCtrl.text;
    var pass = passCtrl.text;
    var url = "https://serene-beach-48273.herokuapp.com/api/login?username=${user}&password=${pass}";
    var response = await http.get(url);
    var token = jsonDecode(response.body)["token"];
    return token;
  }

  Future<List<dynamic>> getPosts(token) async {
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader:"Bearer $token"});
    var posts_json = jsonDecode(response.body);
    return posts_json;
  }

  Future<List<dynamic>> getAdminPosts(token) async {
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/my_posts";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader:"Bearer $token"});
    var posts_json = jsonDecode(response.body);
    return posts_json;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login", style:TextStyle(color:Colors.white))),
      body: 
        Container(
          child: 
            Column(children: <Widget>[
              SizedBox(height: 60),
              Text("Username", style:TextStyle(fontSize: 20), textAlign: TextAlign.right,),
              TextField(controller: userCtrl, style:TextStyle(fontSize: 17, color: Colors.black)),
              SizedBox(height: 40),
              Text("Password", style:TextStyle(fontSize: 20)),
              TextField(controller: passCtrl, style:TextStyle(fontSize: 17, color: Colors.black)),
              SizedBox(height: 30),
              RaisedButton(color: Colors.black, child: Text("Login", style:TextStyle(color: Colors.white)), onPressed: (){stuff(context);},)
            ],
          ),
          margin: EdgeInsets.all(15.0),
      )
    );
  }
}




