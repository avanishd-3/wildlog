// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct UpdateUserInfoMutation: GraphQLMutation {
  public static let operationName: String = "updateUserInfo"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation updateUserInfo($name: String!, $website: String!) { updateBaseUserInfo(name: $name, website: $website) { __typename name website } }"#
    ))

  public var name: String
  public var website: String

  public init(
    name: String,
    website: String
  ) {
    self.name = name
    self.website = website
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "name": name,
    "website": website
  ] }

  public struct Data: WildLogAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.Mutation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("updateBaseUserInfo", UpdateBaseUserInfo?.self, arguments: [
        "name": .variable("name"),
        "website": .variable("website")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      UpdateUserInfoMutation.Data.self
    ] }

    public var updateBaseUserInfo: UpdateBaseUserInfo? { __data["updateBaseUserInfo"] }

    /// UpdateBaseUserInfo
    ///
    /// Parent Type: `User`
    public struct UpdateBaseUserInfo: WildLogAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.User }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("name", String.self),
        .field("website", String?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UpdateUserInfoMutation.Data.UpdateBaseUserInfo.self
      ] }

      public var name: String { __data["name"] }
      public var website: String? { __data["website"] }
    }
  }
}
