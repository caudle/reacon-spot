import 'package:flutter/material.dart';

class Slide extends StatelessWidget {
  const Slide({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    const contents = <SlideContent>[
      SlideContent(
          title: 'First',
          image: 'image goes here',
          description: 'description goes here'),
      SlideContent(
          title: 'second',
          image: 'image goes here',
          description: 'description goes here'),
      SlideContent(
          title: 'third',
          image: 'image goes here',
          description: 'description goes here')
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(contents[index].title),
        Text(contents[index].image),
        Text(contents[index].description),
      ],
    );
  }
}

class SlideContent {
  final String title;
  final String image;
  final String description;

  const SlideContent(
      {required this.title, required this.image, required this.description});
}
