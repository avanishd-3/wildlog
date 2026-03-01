// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct GetUserInfoQuery: GraphQLQuery {
  public static let operationName: String = "getUserInfo"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getUserInfo { me { __typename name email username website bio } }"#
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
      GetUserInfoQuery.Data.self
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
        .field("name", String.self),
        .field("email", String.self),
        .field("username", String.self),
        .field("website", String?.self),
        .field("bio", String?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetUserInfoQuery.Data.Me.self
      ] }

      public var name: String { __data["name"] }
      public var email: String { __data["email"] }
      public var username: String { __data["username"] }
      public var website: String? { __data["website"] }
      public var bio: String? { __data["bio"] }
    }
  }
}
