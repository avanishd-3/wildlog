// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct LikeParkMutation: GraphQLMutation {
  public static let operationName: String = "likePark"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation likePark($parkPublicId: String!) { likePark(parkPublicId: $parkPublicId) }"#
    ))

  public var parkPublicId: String

  public init(parkPublicId: String) {
    self.parkPublicId = parkPublicId
  }

  @_spi(Unsafe) public var __variables: Variables? { ["parkPublicId": parkPublicId] }

  public struct Data: WildLogAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.Mutation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("likePark", Bool?.self, arguments: ["parkPublicId": .variable("parkPublicId")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      LikeParkMutation.Data.self
    ] }

    public var likePark: Bool? { __data["likePark"] }
  }
}
