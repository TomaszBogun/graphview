part of graphview;



class Graph {
  final Set<Node> _nodes = {};
  final Set<Edge> _edges = {};
  List<GraphObserver> graphObserver = [];

  Set<Node> get nodes => _nodes;
  Set<Edge> get edges => _edges;

  var isTree = false;

  int nodeCount() => _nodes.length;

  void addNode(Node node) {
    if (_nodes.add(node)) {
      notifyGraphObserver();
    }
  }

  void addNodes(Iterable<Node> nodes) {
    bool changed = false;
    for (var node in nodes) {
      changed |= _nodes.add(node);
    }
    if (changed) {
      notifyGraphObserver();
    }
  }

  void removeNode(Node? node) {
    if (node == null || !_nodes.contains(node)) return;

    if (isTree) {
      successorsOf(node).forEach(removeNode);
    }

    _nodes.remove(node);
    _edges.removeWhere((edge) => edge.source == node || edge.destination == node);

    notifyGraphObserver();
  }

  void removeNodes(Iterable<Node> nodes) {
    bool changed = false;
    for (var node in nodes) {
      if (_nodes.remove(node)) {
        _edges.removeWhere((edge) => edge.source == node || edge.destination == node);
        changed = true;
      }
    }
    if (changed) {
      notifyGraphObserver();
    }
  }

  Edge addEdge(Node source, Node destination, {Paint? paint}) {
    final edge = Edge(source, destination, paint: paint);
    addEdgeS(edge);
    return edge;
  }

  void addEdgeS(Edge edge) {
    if (_nodes.add(edge.source) | _nodes.add(edge.destination) | _edges.add(edge)) {
      notifyGraphObserver();
    }
  }

  void addEdges(Iterable<Edge> edges) {
    bool changed = false;
    for (var edge in edges) {
      changed |= _nodes.add(edge.source);
      changed |= _nodes.add(edge.destination);
      changed |= _edges.add(edge);
    }
    if (changed) {
      notifyGraphObserver();
    }
  }

  void removeEdge(Edge edge) {
    if (_edges.remove(edge)) {
      notifyGraphObserver();
    }
  }

  void removeEdges(Iterable<Edge> edges) {
    bool changed = false;
    for (var edge in edges) {
      changed |= _edges.remove(edge);
    }
    if (changed) {
      notifyGraphObserver();
    }
  }

  void removeEdgeFromPredecessor(Node? predecessor, Node? current) {
    if (predecessor == null || current == null) return;
    _edges.removeWhere((edge) => edge.source == predecessor && edge.destination == current);
  }

  bool hasNodes() => _nodes.isNotEmpty;

  Edge? getEdgeBetween(Node source, Node? destination) {
    if (destination == null) return null;
    return _edges.firstWhereOrNull((element) => element.source == source && element.destination == destination);
  }

  bool hasSuccessor(Node? node) => _edges.any((element) => element.source == node);

  List<Node> successorsOf(Node? node) => getOutEdges(node!).map((e) => e.destination).toList();

  bool hasPredecessor(Node node) => _edges.any((element) => element.destination == node);

  List<Node> predecessorsOf(Node? node) => getInEdges(node!).map((edge) => edge.source).toList();

  bool contains({Node? node, Edge? edge}) =>
      (node != null && _nodes.contains(node)) || (edge != null && _edges.contains(edge));

  bool containsData(data) => _nodes.any((element) => element.data == data);

  Node getNodeAtPosition(int position) {
    if (position < 0 || position >= _nodes.length) throw RangeError.index(position, _nodes);
    return _nodes.elementAt(position);
  }

  @Deprecated('Please use the builder and id mechanism to build the widgets')
  Node getNodeAtUsingData(Widget data) => _nodes.firstWhere((element) => element.data == data);

  Node getNodeUsingKey(ValueKey key) => _nodes.firstWhere((element) => element.key == key);

  Node getNodeUsingId(dynamic id) => _nodes.firstWhere((element) => element.key == ValueKey(id));

  List<Edge> getOutEdges(Node node) => _edges.where((element) => element.source == node).toList();

  List<Edge> getInEdges(Node node) => _edges.where((element) => element.destination == node).toList();

  void notifyGraphObserver() => graphObserver.forEach((element) => element.notifyGraphInvalidated());

  String toJson() {
    var jsonString = {
      'nodes': _nodes.map((e) => e.hashCode.toString()).toList(),
      'edges': _edges
          .map((e) => {'from': e.source.hashCode.toString(), 'to': e.destination.hashCode.toString()})
          .toList()
    };
    return json.encode(jsonString);
  }
}

class Node {
  ValueKey? key;

  @Deprecated('Please use the builder and id mechanism to build the widgets')
  Widget? data;

  @Deprecated('Please use the Node.Id')
  Node(this.data, {Key? key}) {
    this.key = ValueKey(key?.hashCode ?? data.hashCode);
  }

  Node.Id(dynamic id) {
    key = ValueKey(id);
  }

  Size size = Size.zero;
  Offset position = Offset.zero;

  double get height => size.height;
  double get width => size.width;

  double get x => position.dx;
  double get y => position.dy;

  set y(double value) => position = Offset(position.dx, value);
  set x(double value) => position = Offset(value, position.dy);

  @override
  bool operator ==(Object other) => identical(this, other) || other is Node && hashCode == other.hashCode;

  @override
  int get hashCode => key?.value.hashCode ?? key.hashCode;

  @override
  String toString() {
    return 'Node{position: $position, key: $key, size: $size}';
  }
}

class Edge {
  Node source;
  Node destination;

  Key? key;
  Paint? paint;

  Edge(this.source, this.destination, {this.key, this.paint});

  @override
  bool operator ==(Object other) => identical(this, other) || other is Edge && hashCode == other.hashCode;

  @override
  int get hashCode => Object.hash(source, destination, key);

  @override
  String toString() => 'Edge{source: $source, destination: $destination}';
}

abstract class GraphObserver {
  void notifyGraphInvalidated();
}
