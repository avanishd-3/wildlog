// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct UpdateBioMutation: GraphQLMutation {
  public static let operationName: String = "updateBio"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation updateBio($bio: String!) { updateBio(bio: $bio) { __typename bio } }"#
    ))

  public var bio: String

  public init(bio: String) {
    self.bio = bio
  }

  @_spi(Unsafe) public var __variables: Variables? { ["bio": bio] }

  public struct Data: WildLogAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.Mutation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("updateBio", UpdateBio?.self, arguments: ["bio": .variable("bio")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      UpdateBioMutation.Data.self
    ] }

    public var updateBio: UpdateBio? { __data["updateBio"] }

    /// UpdateBio
    ///
    /// Parent Type: `User`
    public struct UpdateBio: WildLogAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.User }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("bio", String?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UpdateBioMutation.Data.UpdateBio.self
      ] }

      public var bio: String? { __data["bio"] }
    }
  }
}
