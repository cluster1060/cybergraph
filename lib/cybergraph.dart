library cybergraph;


///Thrown when operation applied to unexisted node.
class NodeNotFoundException implements Exception {
  ///Node ID
  int nodeId;

  ///Construct exception with [nodeId]
  NodeNotFoundException(this.nodeId);
}

///Graph class. Contain nodes and edges (both can have data fields attached).
///
///Graph state can be exported to Map (json compatible) for serialization,
///and restored from Map
class Graph {
  ///Nodes
  Map<int, Node> _nodes;

  ///Edges
  Map<int, Edge> _edges;

  ///Direction flag, true means directed.
  bool _directed = false;

  ///Construct graph. For directed graph set [directed] to true, false by default.
  Graph([bool directed]) {
    if (directed != null) this._directed = directed;
    _nodes = new Map<int, Node>();
    _edges = new Map<int, Edge>();
  }

  ///Return true if graph directed, false if not
  bool directed() => _directed;

  ///Adds the new Node to the graph with optional [fields] map. Return new created node.
  Node addNode([Map<String, dynamic> fields]) {
    var node;
    if (fields == null) {
      node = new Node();
    } else {
      node = new Node(fields);
    }
    _nodes[node.id()] = node;
    return node;
  }

  ///Return Node with [nodeId], or null if Node not found
  Node getNode(int nodeId) => _nodes[nodeId];

  ///Adds Edge to the graph with optional fields and direction.
  ///
  ///Return:
  ///New Edge on success.
  ///NodeNotFoundException - if one of the nodes not found.
  ///FormatException - if datafields wrong
  Edge addEdge(Node x, Node y, [Map<String, dynamic> fields, bool directed]) {
    var thisedge;
    bool edgeDirection = _directed;
    //Check for node x existence
    if (!_nodes.containsKey(x.id())) throw NodeNotFoundException(x.id());
    //Check for node y existence
    if (!_nodes.containsKey(y.id())) throw NodeNotFoundException(y.id());
    //Check directed value
    if (directed != null) edgeDirection = directed;

    if (fields == null) {
      thisedge = new Edge(x, y, null, edgeDirection);
    } else {
      thisedge = new Edge(x, y, fields, edgeDirection);
    }
    _edges[thisedge.id()] = thisedge;
    return thisedge;
  }

  ///Return Edge according [edgeId], return null if Edge not found
  Edge getEdge(int edgeId) => _edges[edgeId];

  ///Remove Node with [nodeId] from the graph, also remove all connected edges.
  void removeNode(int nodeId) {
    List<int> removelist = List<int>();
    //Build edges list for removal
    _edges.forEach((key, edge) {
      if (edge.x() == nodeId || edge.y() == nodeId) removelist.add(key);
    });
    //Remove edges
    removelist.forEach((key) {
      _edges.remove(key);
    });
    //Remove node
    _nodes.remove(nodeId);
  }
  //Return all nodes with fields that match [searchfields]
  List<Node> searchNodes(Map<String, dynamic> searchfields) {
    List<Node> _result = new List<Node>();
    //Look through all node
    _nodes.forEach((key,node) {
      bool isNodeFound = false;
      var fields = node.getFields();
      searchfields.forEach((searchkey, searchvalue) {
        if(fields.containsKey(searchkey)) {
          if (fields[searchkey] == searchvalue) {
            isNodeFound = true;
          } else {
            isNodeFound = false;
          }
        }
      });
      if (isNodeFound) {
        _result.add(node);
        isNodeFound = false;
      }
    });
    return _result;
  }

  ///Remove Edge with [edgeId] from the graph.
  void removeEdge(int edgeId) => _edges.remove(edgeId);

  Graph.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("nodes") && json.containsKey("edges")) {
      _nodes = new Map<int, Node>();
      _edges = new Map<int, Edge>();

      for (Map<String, dynamic> jsonnode in json["nodes"]) {
        try {
          var node = new Node.fromJson(jsonnode);
          _nodes[node.id()] = node;
        } catch (e) {
          throw FormatException(e);
        }
      }

      for (Map<String, dynamic> jsonedge in json["edges"]) {
        try {
          var edge = new Edge.fromJson(jsonedge);
          _edges[edge.id()] = edge;
        } catch (e) {
          throw FormatException;
        }
      }
    } else {
      throw FormatException;
    }
  }

  Map<String, dynamic> toJson() {
    var _result = new Map<String, dynamic>();
    List<dynamic> nodeslist = new List<dynamic>();
    List<dynamic> edgeslist = new List<dynamic>();
    _nodes.forEach((id, node) {
      nodeslist.add(node.toJson());
    });
    _edges.forEach((id, edge) {
      edgeslist.add(edge.toJson());
    });
    _result["nodes"] = nodeslist;
    _result["edges"] = edgeslist;

    return _result;
  }

  ///Return nodes list which have edge connection from [node].
  ///If no connections found then return empty list.
  List<Node> neighbors(Node node) {
    List<Edge> selectededges = new List<Edge>();
    List<Node> selectednodes = new List<Node>();
    //Select edges which have connection to node
    _edges.forEach((id, edge) {
      if (edge.x() == node.id() || edge.y() == node.id())
        selectededges.add(edge);
    });
    //Select connected nodes
    for (var edge in selectededges) {
      if (edge.x() == node.id()) {
        //Dont add node nodeId node to result
        selectednodes.add(getNode(edge.y()));
      } else if (edge.y() == node.id()) {
        selectednodes.add(getNode(edge.x()));
      }
    }
    return selectednodes;
  }

  ///Return edges list from the Node [x] to the Node [y];
  ///if edge not found then null
  List<Edge> adjacent(Node x, Node y) {
    List<Edge> _result = new List<Edge>();
    _edges.forEach((id, edge) {
      if ((edge.x() == x.id()) && (edge.y() == y.id())) {
        _result.add(edge);
      } else if ((edge.x() == y.id() && edge.y() == x.id())) {
        _result.add(edge);
      }
    });
    return _result;
  }
}

///Graph [Node] class. Contain Node ID and associated data fields in Map format.
class Node {
  ///Node ID
  int _id;

  ///Node datafields map
  Map<String, dynamic> _fields;

  ///Construct new node with given [fields].
  Node([Map<String, dynamic> fields]) {
    if (fields == null) {
      _fields = Map<String, dynamic>();
    } else {
      _fields = fields;
    }
    _id = hashCode;
  }

  ///Construct Node from [json] deserelized data (Map).
  ///
  ///Throw [FormatException] in case [json] have no 'id' & 'fields' values.
  Node.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('id') && json.containsKey('fields')) {
      _id = json['id'];
      _fields = json['fields'];
    } else {
      throw FormatException(json.toString());
    }
  }

  ///Return Node ID
  int id() => _id;

  ///Return map of [fields] defined for this Node
  Map<String, dynamic> getFields() => _fields;

  //Set Node fields from deserilised map
  setFields(Map<String, dynamic> fields) => this._fields = fields;

  ///Return map with Node data ready for json serialization.
  Map<String, dynamic> toJson() => {'id': _id, 'fields': _fields};
}

///Graph [Edge] class.
///
///Contain Edge id, connected Nodes id's, directed flag and data fields in Map format.
class Edge {
  ///Edge id.
  int _id;

  ///Connected Node id.
  int _x;

  ///Connected Node id.
  int _y;

  ///Direction flag. True if Edge directed from x to y, false if not. False by default.
  bool _directed = false;

  ///Data fields in Map format.
  Map<String, dynamic> _fields;

  ///Construct Edge between two graph nodes [x] & [y]. Optionaly use data [fields] in Map format
  ///and [directed] flag (edge not directed if ommited).
  Edge(Node x, Node y, [Map<String, dynamic> fields, bool directed]) {
    this._x = x.id();
    this._y = y.id();

    ///if flag not set use default.
    if (directed != null) _directed = directed;

    ///if fields not set then create empty fields list.
    if (fields == null) {
      _fields = new Map<String, dynamic>();
    } else {
      _fields = fields;
    }
    _id = hashCode;
  }

  ///Construct Edge from [json] deserelized data (Map).
  ///
  ///Throw [FormatException] in case [json] lack one of 'id', 'x', 'y', 'fields', 'directed' values.
  Edge.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('id') &&
        json.containsKey('x') &&
        json.containsKey('y') &&
        json.containsKey('fields') &&
        json.containsKey('directed')) {
      _id = json['id'];
      _x = json['x'];
      _y = json['y'];
      _directed = json['directed'];
      _fields = json['fields'];
    } else {
      throw FormatException(json.toString());
    }
  }

  ///Return Edge id.
  int id() => _id;

  ///Return connected node id.
  int x() => _x;

  ///Return connected node id.
  int y() => _y;

  ///Return edge type. [true] if directed, [false] if not.
  bool directed() => _directed;

  ///Return map of [fields] defined for this Edge
  Map<String, dynamic> getFields() => _fields;

  ///Set edge data [fields]. All current fields will be replaced
  setFields(Map<String, dynamic> fields) => this._fields = fields;

  ///Return map with Edge data ready for json serialization.
  Map<String, dynamic> toJson() =>
      {'id': _id, 'x': _x, 'y': _y, 'directed': _directed, 'fields': _fields};
}