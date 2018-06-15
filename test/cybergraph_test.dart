import 'package:test/test.dart';
import 'dart:convert';
import 'package:cybergraph/cybergraph.dart';


void main() {
  setUp(() {});

  test('Node class test', () async {
    //Default constructor test. Node() test (without fields)
    var node1 = Node();
    expect(node1.getFields().isEmpty, true);
    expect(node1.id(), node1.hashCode);
    //Constructor with data fields test. Node(fields).
    Map<String, dynamic> node1fields = {'title': 'Node 1', 'type': 'book'};
    node1 = Node(node1fields);
    expect(node1.getFields()["title"], "Node 1");
    expect(node1.getFields()["type"], "book");
    //Constructor from json data map test. Node.fromJson(json).
    var node2json =
        '{ "id": 100, "fields": { "title": "Node 2", "type": "chapter"}}';
    var node2 = Node.fromJson(json.decode(node2json));
    //Also test Node.id(), Node.getFields() functions.
    expect(node2.id(), 100);
    expect(node2.getFields()["title"], "Node 2");
    expect(node2.getFields()["type"], "chapter");
    //Node to json data map conversion test. Node.toJson()
    expect(node2.toJson()["fields"]["title"], "Node 2");
    //Constructor .fromJson() data test with wrong json data (test for FormatException).
    //no fields
    var wrongjson = '{ "id": 100 }';
    try {
      Node.fromJson(json.decode(wrongjson));
    } catch (e) {
      expect(e.runtimeType, FormatException);
    }
  });

  test('Edge class test', () async {
    //Default constructor test. Edge(node1, node2) test (without data fields)
    Map<String, dynamic> node1fields = {'title': 'Node 1', 'type': 'book'};
    var node1 = new Node(node1fields);
    Map<String, dynamic> node2fields = {'title': 'Node 2', 'type': 'chapter'};
    var node2 = new Node(node2fields);

    var edge1 = new Edge(node1, node2);
    //Also test for Edge.x() & Edge.y() functions
    expect(edge1.x(), node1.id());
    expect(edge1.y(), node2.id());
    //Default constructor test. Edge(node1, node2) test (with data fields) and direction
    Map<String, dynamic> edge1fields = {
      'title': 'Book chapters',
      'type': 'chapters'
    };
    edge1 = new Edge(node1, node2, edge1fields, true);
    expect(edge1.x(), node1.id());
    expect(edge1.y(), node2.id());
    //Also test for Edge.getFields() & Edge.directed() functions
    expect(edge1.getFields()["title"], 'Book chapters');
    expect(edge1.getFields()["type"], 'chapters');
    expect(edge1.directed(), true);

    //Constructor from json data map test. Edge.fromJson(json).
    var edge1json =
        '{ "id": 100, "x": ${node1.id()}, "y": ${node2.id()}, "directed": true, "fields": { "title": "Book chapters", "type": "chapters"}}';
    edge1 = new Edge.fromJson(json.decode(edge1json));
    expect(edge1.id(), 100);
    expect(edge1.x(), node1.id());
    expect(edge1.y(), node2.id());
    expect(edge1.getFields()["title"], "Book chapters");
    expect(edge1.getFields()["type"], "chapters");

    //Constructor .fromJson() data test with wrong json data (test for FormatException).
    //no fields
    var wrongjson =
        '{ "id": 100, "x": ${node1.id()}, "y": ${node1.id()}, "directed": true}';
    try {
      new Node.fromJson(json.decode(wrongjson));
    } catch (e) {
      expect(e.runtimeType, FormatException);
    }
    //Edge to json data map conversion test. Edge.toJson()
    expect(edge1.toJson()["fields"]["title"], "Book chapters");
  });

  test('Graph class test', () async {
    //Construct directed graph
    var graph = new Graph(true);
    expect(graph.directed(), true);

    //Test nodes addition. Graph.addNode() function
    Map<String, dynamic> node1fields = {'title': 'Node 1', 'type': 'book'};
    Map<String, dynamic> node2fields = {'title': 'Node 2', 'type': 'chapter'};
    Map<String, dynamic> node3fields = {'title': 'Node 3', 'type': 'chapter'};
    Map<String, dynamic> node4fields = {'title': 'Node 4', 'type': 'section'};
    Map<String, dynamic> node5fields = {'title': 'Node 5', 'type': 'text'};
    Map<String, dynamic> node6fields = {'title': 'Node 6', 'type': 'text'};
    var node1 = graph.addNode(node1fields);
    var node2 = graph.addNode(node2fields);
    var node3 = graph.addNode(node3fields);
    var node4 = graph.addNode(node4fields);
    var node5 = graph.addNode(node5fields);
    var node6 = graph.addNode(node6fields);
    //Test for getNode() function
    expect(graph.getNode(node1.id()).id(), node1.id());

    //Test edges addition. Graph.addEdge() & Graph.getEdge() functions
    var edge1fields = {'title': 'Book chapter 1', 'type': 'chapters'};
    //var edge2fields = {'title': 'Book chapter 2', 'type': 'chapters'};
    var edge3fields = {'title': 'Chapter section', 'type': 'sections'};
    //var edge4fields = {'title': 'Section text 1', 'type': 'texts'};
    var edge5fields = {'title': 'Section text 2', 'type': 'texts'};
    var edge1 = graph.addEdge(node1, node2, edge1fields);
    //var edge2 = graph.addEdge(node1, node3, edge2fields);
    var edge3 = graph.addEdge(node2, node4, edge3fields, true);
    //var edge4 = graph.addEdge(node4, node5, edge4fields, true);
    var edge5 = graph.addEdge(node4, node6, edge5fields, true);
    //Test for edge addition
    expect(graph.getEdge(edge1.id()).x(), node1.id());
    expect(graph.getEdge(edge3.id()).directed(), true);
    //Test Graph.neighbors(node) function
    expect(graph.neighbors(node1).length,1);
    expect(graph.neighbors(node3).length,0);
    expect(graph.neighbors(node2).length,2);
    expect(graph.neighbors(node5).length,0);
    expect(graph.neighbors(node4).length,2);
    //Test Graph.adjacent(node,node)
    expect(graph.adjacent(node1, node2).length, 1);
    //Test Graph.toJson() & Graph.fromJson(json) functions
    var graphState = graph.toJson();
    expect(graphState.containsKey("nodes"), true);
    expect(graphState.containsKey("edges"), true);
    var graphRestored = new Graph.fromJson(graphState);
    expect(graphRestored.getNode(node1.id()).getFields()["title"], node1.getFields()["title"]);
    expect(graphRestored.getEdge(edge1.id()).getFields()["title"], edge1.getFields()["title"]);
    //Test Graph.searchNodes(searchfields)
    expect(graph.searchNodes(node1fields).length, 1);
    //Node removal test. Graph.removeNode()
    graph.removeNode(node6.id());
    expect(graph.getNode(node6.id()), null);
    expect(graph.getEdge(edge5.id()), null);
  
  });
}