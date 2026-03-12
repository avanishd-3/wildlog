// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct LikeAndBucketListStatusQuery: GraphQLQuery {
  public static let operationName: String = "LikeAndBucketListStatus"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query LikeAndBucketListStatus($parkPublicId: String!) { isParkLiked(parkPublicId: $parkPublicId) isParkBucketListed(parkPublicId: $parkPublicId) }"#
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
      .field("isParkLiked", Bool?.self, arguments: ["parkPublicId": .variable("parkPublicId")]),
      .field("isParkBucketListed", Bool?.self, arguments: ["parkPublicId": .variable("parkPublicId")]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      LikeAndBucketListStatusQuery.Data.self
    ] }

    public var isParkLiked: Bool? { __data["isParkLiked"] }
    public var isParkBucketListed: Bool? { __data["isParkBucketListed"] }
  }
}
