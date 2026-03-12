// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct SubmitReviewMutation: GraphQLMutation {
  public static let operationName: String = "submitReview"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation submitReview($parkPublicId: String!, $review: String!, $rating: String!, $visitedAt: String!) { mutateReview( parkPublicId: $parkPublicId review: $review rating: $rating visitedAt: $visitedAt ) }"#
    ))

  public var parkPublicId: String
  public var review: String
  public var rating: String
  public var visitedAt: String

  public init(
    parkPublicId: String,
    review: String,
    rating: String,
    visitedAt: String
  ) {
    self.parkPublicId = parkPublicId
    self.review = review
    self.rating = rating
    self.visitedAt = visitedAt
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "parkPublicId": parkPublicId,
    "review": review,
    "rating": rating,
    "visitedAt": visitedAt
  ] }

  public struct Data: WildLogAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.Mutation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("mutateReview", Bool?.self, arguments: [
        "parkPublicId": .variable("parkPublicId"),
        "review": .variable("review"),
        "rating": .variable("rating"),
        "visitedAt": .variable("visitedAt")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      SubmitReviewMutation.Data.self
    ] }

    public var mutateReview: Bool? { __data["mutateReview"] }
  }
}
