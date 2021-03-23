import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'dart:io' as io;

import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/models/documents/nodes/line.dart';
import 'package:flutter_quill/models/documents/nodes/node.dart';
import 'package:flutter_quill/models/documents/nodes/leaf.dart' hide Text;
import 'package:flutter_quill/models/documents/nodes/block.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/text_line.dart';
import 'package:flutter_quill/widgets/text_line.dart';
import 'package:flutter_quill/widgets/text_line.dart';
import '../widgets/demo_scaffold.dart';

class ReadOnlyPage extends StatefulWidget {
  @override
  _ReadOnlyPageState createState() => _ReadOnlyPageState();
}

class _ReadOnlyPageState extends State<ReadOnlyPage> {
  final FocusNode _focusNode = FocusNode();

  bool _edit = false;
  late Document document;

  @override
  void initState() {
    super.initState();
    _loadFromAssets();
  }

  Future<void> _loadFromAssets() async {
    try {
      final result = await rootBundle.loadString('assets/sample_data.json');
      document = Document.fromJson(jsonDecode(result));
      setState(() {});
    } catch (error) {}
  }

  Widget _defaultEmbedBuilder(BuildContext context, Embed node) {
    switch (node.value.type) {
      case 'image':
        String imageUrl = node.value.data;
        return imageUrl.startsWith('http')
            ? Container(
                color: Colors.green,
                width: 30,
                height: 30,
                child: Image.network(imageUrl),
              )
            : Image.file(io.File(imageUrl));
      default:
        throw UnimplementedError('Embeddable type "${node.value.type}" is not supported by default embed '
            'builder of QuillEditor. You must pass your own builder function to '
            'embedBuilder property of QuillEditor or QuillField widgets.');
    }
  }

  List<Widget> _buildChildren(BuildContext context) {
    Document doc = document;
    final result = <Widget>[];
    Map<int, int> indentLevelCounts = {};
    for (Node node in doc.root.children) {
      if (node is Line) {
        TextLine textLine = TextLine(
          line: node,
          textDirection: TextDirection.ltr,
          styles: DefaultStyles.getInstance(context),
          embedBuilder: _defaultEmbedBuilder,
        );
        if (node.hasEmbed) {
          Embed embed = node.children.single as Embed;
          // result.add(_defaultEmbedBuilder(context, embed));
        }
        // result.add(Text('你好2', style: TextStyle(color: Colors.red)));
        // result.add(RichText(
        //   text: TextSpan(text: '你好', style: TextStyle(color: Colors.red)),
        //   textScaleFactor: MediaQuery.textScaleFactorOf(context),
        // ));
        result.add(textLine);
        // result.add(Align(alignment: Alignment.centerLeft, child: Container(color: Colors.blue, margin: EdgeInsets.only(right: 6, bottom: 6), child: textLine)));
      } else if (node is Block) {
        Widget ww = Align(
          alignment: Alignment.centerLeft,
          child: Container(
            color: Colors.red,
            margin: EdgeInsets.only(top: 8),
            width: 30,
            height: 30,
          ),
        );
        result.add(ww);
      } else {
        throw StateError('Unreachable.');
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      documentFilename: 'sample_data.json',
      builder: _buildContent,
      showToolbar: _edit == true,
    );
  }

  Widget _buildContent(BuildContext context, QuillController? controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Wrap(
          children: _buildChildren(context),
          // children: [
          //   Text('你好2', style: TextStyle(color: Colors.red)),
          //   Container(
          //     color: Colors.green,
          //     width: 30,
          //     height: 30,
          //     child: Image.network('https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png'),
          //   )
          // ],
        ),
      ),
    );
  }

  void _toggleEdit() {
    setState(() {
      _edit = !_edit;
    });
  }
}
