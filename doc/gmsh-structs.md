# GMSH meshes in Julia

::: mermaid
classDiagram
    class GmshMesh {
      version: Version
      physicalNames: physicalName[]
      entities: EntityCollection
      nodeBlocks: NodeBlockCollection
      elementBlocks: ElementBlockCollection
    }
    class Version {
      version: Float
      fileType: Int
      dataSize: Int
    }
    class PhysicalNameCollection {
      nNames: Int
      names: PhysicalName[]
    }
    class PhysicalName {
      dimension: Int
      tag: Int
      name: String
    }
    class BoundingBox {
      bounds: Float[]
    }
    class EntityCollection {
      points: Point[]
      curves: Entity[]
      surfaces: Entity[]
      volumes: Entity[]
    }
    class Point {
      tag: Int
      position: Float[]
      physicalTags: Int[]
    }
    class Entity {
        tag: Int
        bb: BoundingBox
        physicalTags: Int[]
        boundingEntities: Int[]
    }
    class NodeBlockCollection {
      nBlocks: Int
      nNodes: Int
      minNodeTag: Int
      maxNodeTag: Int
      nodeBlocks: NodeBlock[]
    }
    class NodeBlock {       
      entityDim: Int
      entityTag: Int
      parametric: Bool
      tags: Int[]
      coordinates: Float[][]
    }
    class ElementBlockCollection {
      nBlocks: Int
      nElements: Int
      minElementTag: Int
      maxElementTag: Int
      elementBlocks: ElementBlock[]
    }
    class ElementBlock {
        entityDim: Int
        entityTag: Int
        elementType: Int
        elementTags: Int[]
        nodeTags: Int[][]
    }

    GmshMesh o-- Version
    GmshMesh o-- PhysicalNameCollection
    PhysicalNameCollection o-- PhysicalName
    GmshMesh o-- EntityCollection
    GmshMesh o-- NodeBlockCollection
    NodeBlockCollection o-- NodeBlock
    GmshMesh o-- ElementBlockCollection
    ElementBlockCollection o-- ElementBlock
    EntityCollection o-- "*" Point
    EntityCollection o-- "*" Entity
    Entity o-- "1" BoundingBox
:::



