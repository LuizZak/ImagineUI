/*
    The following code is based off of Velcro Physics/Farseer Physics Engine,
    the license of which is written bellow:

    MIT License

    Copyright (c) 2017 Ian Qvist

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
*/

class QuadTree<T> {
    var MaxBucket: Int
    var MaxDepth: Int
    var Nodes: [QuadTreeElement<T>]
    var Span: UIRectangle
    var SubTrees: [QuadTree<T>]?
    
    var IsPartitioned: Bool {
        SubTrees != nil
    }

    init(_ span: UIRectangle, _ maxBucket: Int, _ maxDepth: Int) {
        Span = span
        Nodes = []

        MaxBucket = maxBucket
        MaxDepth = maxDepth
    }

    func AddNode(_ node: QuadTreeElement<T>) {
        if let subTrees = SubTrees { //we already have children nodes
            //
            //add node to specific sub-tree
            //
            switch (Partition(Span, node.Span)) {
                case 1: //quadrant 1
                    subTrees[0].AddNode(node)
                    
                case 2:
                    subTrees[1].AddNode(node)
                    
                case 3:
                    subTrees[2].AddNode(node)
                    
                case 4:
                    subTrees[3].AddNode(node)
                    
                default:
                    node.Parent = self
                    Nodes.append(node)
            }
        } else {
            if (Nodes.count >= MaxBucket && MaxDepth > 0) { //bin is full and can still subdivide
                //
                //partition into quadrants and sort existing nodes amongst quads.
                //
                Nodes.append(node) //treat new node just like other nodes for partitioning

                let subTrees = [
                    QuadTree<T>(Q1(Span), MaxBucket, MaxDepth - 1),
                    QuadTree<T>(Q2(Span), MaxBucket, MaxDepth - 1),
                    QuadTree<T>(Q3(Span), MaxBucket, MaxDepth - 1),
                    QuadTree<T>(Q4(Span), MaxBucket, MaxDepth - 1),
                ]

                var remNodes: [QuadTreeElement<T>] = []
                //nodes that are not fully contained by any quadrant

                for n in Nodes {
                    switch (Partition(Span, n.Span)) {
                        case 1: //quadrant 1
                            subTrees[0].AddNode(n)
                            
                        case 2:
                            subTrees[1].AddNode(n)
                            
                        case 3:
                            subTrees[2].AddNode(n)
                            
                        case 4:
                            subTrees[3].AddNode(n)
                            
                        default:
                            n.Parent = self
                            remNodes.append(n)
                    }
                }

                SubTrees = subTrees

                Nodes = remNodes
            } else {
                node.Parent = self
                Nodes.append(node)
                //if bin is not yet full or max depth has been reached, just add the node without subdividing
            }
        }
    }
    
    func OverlapsElement(_ searchR: UIRectangle) -> Bool {
        var stack: [QuadTree<T>] = []
        stack.append(self)

        while let qt = stack.popLast() {
            if !TestOverlap(searchR, qt.Span) {
                continue
            }

            for n in qt.Nodes {
                if TestOverlap(searchR, n.Span) {
                    return true
                }
            }
            
            if let subTrees = qt.SubTrees {
                for st in subTrees {
                    stack.append(st)
                }
            }
        }

        return false
    }

    func QueryAabb(predicate callback: (QuadTreeElement<T>) -> Bool, searchR: UIRectangle) {
        var stack: [QuadTree<T>] = []
        stack.append(self)

        while let qt = stack.popLast() {
            if (!TestOverlap(searchR, qt.Span)) {
                continue
            }

            for n in qt.Nodes {
                if (!TestOverlap(searchR, n.Span)) {
                    continue
                }

                if (!callback(n)) {
                    return
                }
            }

            if let subTrees = qt.SubTrees {
                for st in subTrees {
                    stack.append(st)
                }
            }
        }
    }

    func QueryAabbAny(predicate callback: (QuadTreeElement<T>) -> Bool, searchR: UIRectangle) -> Bool {
        var stack: [QuadTree<T>] = []
        stack.append(self)

        while let qt = stack.popLast() {
            if !TestOverlap(searchR, qt.Span) {
                continue
            }

            for n in qt.Nodes {
                if !TestOverlap(searchR, n.Span) {
                    continue
                }
                if callback(n) {
                    return true
                }
            }

            if let subTrees = qt.SubTrees {
                for st in subTrees {
                    stack.append(st)
                }
            }
        }

        return false
    }

    func GetAllNodesR(_ nodes: inout [QuadTreeElement<T>]) {
        nodes.append(contentsOf: Nodes)
        
        if let subTrees = SubTrees {
            for st in subTrees {
                st.GetAllNodesR(&nodes)
            }
        }
    }

    func RemoveNode(_ node: QuadTreeElement<T>) {
        node.Parent?.Nodes.removeAll(where: { $0 === node })
    }

    func Reconstruct() {
        var allNodes: [QuadTreeElement<T>] = []
        GetAllNodesR(&allNodes)

        Clear()

        allNodes.forEach(AddNode)
    }

    func Clear() {
        Nodes.removeAll()
        SubTrees = nil
    }

    private func TestOverlap(_ a: UIRectangle, _ b: UIRectangle) -> Bool {
        let d1X = b.minimum.x - a.maximum.x
        let d1Y = b.minimum.y - a.maximum.y

        let d2X = a.minimum.x - b.maximum.x
        let d2Y = a.minimum.y - b.maximum.y
        
        if (d1X > 0.0 || d1Y > 0.0) {
            return false
        }
        if (d2X > 0.0 || d2Y > 0.0) {
            return false
        }

        return true
    }

    /// <summary>
    /// returns the quadrant of span that entirely contains test. if none, return 0.
    /// </summary>
    /// <param name="span"></param>
    /// <param name="test"></param>
    /// <returns></returns>
    private func Partition(_ span: UIRectangle, _ test: UIRectangle) -> Int {
        if (Q1(span).contains(test)) { return 1 }
        if (Q2(span).contains(test)) { return 2 }
        if (Q3(span).contains(test)) { return 3 }
        if (Q4(span).contains(test)) { return 4 }

        return 0
    }

    private func Q1(_ aabb: UIRectangle) -> UIRectangle {
        return UIRectangle(minimum: aabb.center, maximum: aabb.maximum)
    }

    private func Q2(_ aabb: UIRectangle) -> UIRectangle {
        return UIRectangle(minimum: UIPoint(x: aabb.minimum.x, y: aabb.center.y), maximum: UIPoint(x: aabb.center.x, y: aabb.maximum.y))
    }

    private func Q3(_ aabb: UIRectangle) -> UIRectangle {
        return UIRectangle(minimum: aabb.minimum, maximum: aabb.center)
    }

    private func Q4(_ aabb: UIRectangle) -> UIRectangle {
        return UIRectangle(minimum: UIPoint(x: aabb.center.x, y: aabb.minimum.y), maximum: UIPoint(x: aabb.maximum.x, y: aabb.center.y))
    }
}

class QuadTreeElement<T> {
    weak var Parent: QuadTree<T>?
    var Span: UIRectangle
    var Value: T

    init(_ value: T, _ span: UIRectangle) {
        Span = span
        Value = value
        Parent = nil
    }
}
