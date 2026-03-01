// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct MeQuery: GraphQLQuery {
  public static let operationName: String = "me"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query me { me { __typename id } }"#
    ))

  public init() {}

  public struct Data: WildLogAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("me", Me?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      MeQuery.Data.self
    ] }

    public var me: Me? { __data["me"] }

    /// Me
    ///
    /// Parent Type: `User`
    public struct Me: WildLogAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.User }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MeQuery.Data.Me.self
      ] }

      public var id: String { __data["id"] }
    }
  }
}
