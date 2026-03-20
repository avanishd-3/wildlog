// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct GetBucketListedParksQuery: GraphQLQuery {
  public static let operationName: String = "getBucketListedParks"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getBucketListedParks { bucketListedParks { __typename id name description designation latitude longitude states type cost free imageUrl } }"#
    ))

  public init() {}

  public struct Data: WildLogAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("bucketListedParks", [BucketListedPark].self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetBucketListedParksQuery.Data.self
    ] }

    /// Get all parks that the current user has bucket listed
    public var bucketListedParks: [BucketListedPark] { __data["bucketListedParks"] }

    /// BucketListedPark
    ///
    /// Parent Type: `Park`
    public struct BucketListedPark: WildLogAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.Park }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", String.self),
        .field("name", String.self),
        .field("description", String.self),
        .field("designation", GraphQLEnum<WildLogAPI.ParkDesignationEnum>.self),
        .field("latitude", Double?.self),
        .field("longitude", Double?.self),
        .field("states", String.self),
        .field("type", GraphQLEnum<WildLogAPI.ParkTypeEnum>.self),
        .field("cost", Int.self),
        .field("free", Bool.self),
        .field("imageUrl", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetBucketListedParksQuery.Data.BucketListedPark.self
      ] }

      public var id: String { __data["id"] }
      public var name: String { __data["name"] }
      public var description: String { __data["description"] }
      public var designation: GraphQLEnum<WildLogAPI.ParkDesignationEnum> { __data["designation"] }
      public var latitude: Double? { __data["latitude"] }
      public var longitude: Double? { __data["longitude"] }
      public var states: String { __data["states"] }
      public var type: GraphQLEnum<WildLogAPI.ParkTypeEnum> { __data["type"] }
      public var cost: Int { __data["cost"] }
      public var free: Bool { __data["free"] }
      public var imageUrl: String { __data["imageUrl"] }
    }
  }
}
