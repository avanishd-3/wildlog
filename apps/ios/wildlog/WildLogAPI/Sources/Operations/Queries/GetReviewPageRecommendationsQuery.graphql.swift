// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct GetReviewPageRecommendationsQuery: GraphQLQuery {
  public static let operationName: String = "getReviewPageRecommendations"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getReviewPageRecommendations { meReviews { __typename id parkName rating reviewText visitedDate } friendReviews { __typename id authorName parkName rating reviewText visitedDate } }"#
    ))

  public init() {}

  public struct Data: WildLogAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("meReviews", [MeReview]?.self),
      .field("friendReviews", [FriendReview]?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetReviewPageRecommendationsQuery.Data.self
    ] }

    public var meReviews: [MeReview]? { __data["meReviews"] }
    public var friendReviews: [FriendReview]? { __data["friendReviews"] }

    /// MeReview
    ///
    /// Parent Type: `ReviewDetailed`
    public struct MeReview: WildLogAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.ReviewDetailed }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", String.self),
        .field("parkName", String.self),
        .field("rating", String.self),
        .field("reviewText", String?.self),
        .field("visitedDate", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetReviewPageRecommendationsQuery.Data.MeReview.self
      ] }

      public var id: String { __data["id"] }
      public var parkName: String { __data["parkName"] }
      public var rating: String { __data["rating"] }
      public var reviewText: String? { __data["reviewText"] }
      public var visitedDate: String { __data["visitedDate"] }
    }

    /// FriendReview
    ///
    /// Parent Type: `ReviewDetailed`
    public struct FriendReview: WildLogAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.ReviewDetailed }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", String.self),
        .field("authorName", String.self),
        .field("parkName", String.self),
        .field("rating", String.self),
        .field("reviewText", String?.self),
        .field("visitedDate", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetReviewPageRecommendationsQuery.Data.FriendReview.self
      ] }

      public var id: String { __data["id"] }
      public var authorName: String { __data["authorName"] }
      public var parkName: String { __data["parkName"] }
      public var rating: String { __data["rating"] }
      public var reviewText: String? { __data["reviewText"] }
      public var visitedDate: String { __data["visitedDate"] }
    }
  }
}
