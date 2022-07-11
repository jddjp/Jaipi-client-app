/// Flutter code sample for ListTile

// Here is an example of a custom list item that resembles a Youtube related
// video list item created with [Expanded] and [Container] widgets.
//
// ![Custom list item a](https://flutter.github.io/assets-for-api-docs/assets/widgets/custom_list_item_a.png)

import 'package:flutter/material.dart';

class CustomListItem extends StatelessWidget {
  const CustomListItem({
    this.thumbnail,
    this.title,
    this.user,
    this.viewCount,
  });

  final Widget thumbnail;
  final String title;
  final String user;
  final int viewCount;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        margin: EdgeInsets.fromLTRB(0, 0, 2.0, 7.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)
        ),
      child: InkWell(
        splashColor: Colors.blue.withAlpha(20),
        onTap: () {},
        child: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 15.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: thumbnail,
              ),
              Expanded(
                flex: 2,
                child: _VideoDescription(
                  title: title,
                  user: user,
                  viewCount: viewCount,
                ),
              ),
              
            ],
          ),
        ),
      ]),
      )
      
    ),
    );
  }
}

class _VideoDescription extends StatelessWidget {
  const _VideoDescription({
    Key key,
    this.title,
    this.user,
    this.viewCount,
  }) : super(key: key);

  final String title;
  final String user;
  final int viewCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0)),
              Text(
                '$viewCount views',
                style: const TextStyle(fontSize: 10.0),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.star,
                size: 16.0,
                color: Colors.yellowAccent,
              ),
              Text(
                '$viewCount views ',
                style: const TextStyle(fontSize: 10.0),
              ),
              const Icon(
                Icons.watch,
                size: 16.0,
              ),
              Text(
                '$viewCount views ',
                style: const TextStyle(fontSize: 10.0),
              ),
            ],
          )
        ],
      ),
    );
  }
}

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatelessWidget {
  MyStatelessWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(10.0),
      itemExtent: 110.0,
      children: <CustomListItem>[
        CustomListItem(
          user: 'Flutter',
          viewCount: 999000,
          thumbnail: CircleAvatar(
            radius: 32,
          ),
          title: 'The Flutter YouTube Channel',
        ),
        
        CustomListItem(
          user: 'Dash',
          viewCount: 884000,
          thumbnail: CircleAvatar(
            radius: 32,
          ),
          title: 'Announcing Flutter 1.0',
        ),
      ],
    );
  }
}
