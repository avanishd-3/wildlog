// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct GetUserReviewQuery: GraphQLQuery {
  public static let operationName: String = "getUserReview"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getUserReview($parkPublicId: String!) { getUserReview(parkPublicId: $parkPublicId) { __typename rating reviewText visitedAt } }"#
    ))

  public var parkPublicId: String

  public init(parkPublicId: String) {
    self.parkPublicId = parkPublicId
  }

  @_spi(Unsafe) public var __variables: Variables? { ["parkPublicId": parkPublicId] }

  public struct Data: WildLogAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("getUserReview", GetUserReview?.self, arguments: ["parkPublicId": .variable("parkPublicId")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetUserReviewQuery.Data.self
    ] }

    public var getUserReview: GetUserReview? { __data["getUserReview"] }

    /// GetUserReview
    ///
    /// Parent Type: `Review`
    public struct GetUserReview: WildLogAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.Review }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("rating", String.self),
        .field("reviewText", String?.self),
        .field("visitedAt", String?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetUserReviewQuery.Data.GetUserReview.self
      ] }

      public var rating: String { __data["rating"] }
      public var reviewText: String? { __data["reviewText"] }
      public var visitedAt: String? { __data["visitedAt"] }
    }
  }
}
