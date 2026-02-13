// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct CreateParkMutation: GraphQLMutation {
  public static let operationName: String = "CreatePark"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreatePark($description: String!, $designation: ParkDesignationEnum!, $name: String!) { createPark(description: $description, designation: $designation, name: $name) { __typename id name description designation } }"#
    ))

  public var description: String
  public var designation: GraphQLEnum<ParkDesignationEnum>
  public var name: String

  public init(
    description: String,
    designation: GraphQLEnum<ParkDesignationEnum>,
    name: String
  ) {
    self.description = description
    self.designation = designation
    self.name = name
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "description": description,
    "designation": designation,
    "name": name
  ] }

  public struct Data: WildLogAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.Mutation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("createPark", CreatePark?.self, arguments: [
        "description": .variable("description"),
        "designation": .variable("designation"),
        "name": .variable("name")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      CreateParkMutation.Data.self
    ] }

    public var createPark: CreatePark? { __data["createPark"] }

    /// CreatePark
    ///
    /// Parent Type: `Park`
    public struct CreatePark: WildLogAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.Park }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", String.self),
        .field("name", String.self),
        .field("description", String.self),
        .field("designation", GraphQLEnum<WildLogAPI.ParkDesignationEnum>.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CreateParkMutation.Data.CreatePark.self
      ] }

      public var id: String { __data["id"] }
      public var name: String { __data["name"] }
      public var description: String { __data["description"] }
      public var designation: GraphQLEnum<WildLogAPI.ParkDesignationEnum> { __data["designation"] }
    }
  }
}
