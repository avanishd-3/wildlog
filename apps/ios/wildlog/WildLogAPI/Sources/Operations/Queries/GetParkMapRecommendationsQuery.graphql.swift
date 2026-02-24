// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct GetParkMapRecommendationsQuery: GraphQLQuery {
  public static let operationName: String = "GetParkMapRecommendations"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetParkMapRecommendations($filters: ParkFiltersInput, $x_max: Float!, $x_min: Float!, $y_max: Float!, $y_min: Float!) { getParkMapRecommendations( filters: $filters x_max: $x_max x_min: $x_min y_max: $y_max y_min: $y_min ) { __typename id name description designation latitude longitude states type } }"#
    ))

  public var filters: GraphQLNullable<ParkFiltersInput>
  public var x_max: Double
  public var x_min: Double
  public var y_max: Double
  public var y_min: Double

  public init(
    filters: GraphQLNullable<ParkFiltersInput>,
    x_max: Double,
    x_min: Double,
    y_max: Double,
    y_min: Double
  ) {
    self.filters = filters
    self.x_max = x_max
    self.x_min = x_min
    self.y_max = y_max
    self.y_min = y_min
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "filters": filters,
    "x_max": x_max,
    "x_min": x_min,
    "y_max": y_max,
    "y_min": y_min
  ] }

  public struct Data: WildLogAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { WildLogAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("getParkMapRecommendations", [GetParkMapRecommendation]?.self, arguments: [
        "filters": .variable("filters"),
        "x_max": .variable("x_max"),
        "x_min": .variable("x_min"),
        "y_max": .variable("y_max"),
        "y_min": .variable("y_min")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      GetParkMapRecommendationsQuery.Data.self
    ] }

    public var getParkMapRecommendations: [GetParkMapRecommendation]? { __data["getParkMapRecommendations"] }

    /// GetParkMapRecommendation
    ///
    /// Parent Type: `Park`
    public struct GetParkMapRecommendation: WildLogAPI.SelectionSet {
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
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetParkMapRecommendationsQuery.Data.GetParkMapRecommendation.self
      ] }

      public var id: String { __data["id"] }
      public var name: String { __data["name"] }
      public var description: String { __data["description"] }
      public var designation: GraphQLEnum<WildLogAPI.ParkDesignationEnum> { __data["designation"] }
      public var latitude: Double? { __data["latitude"] }
      public var longitude: Double? { __data["longitude"] }
      public var states: String { __data["states"] }
      public var type: GraphQLEnum<WildLogAPI.ParkTypeEnum> { __data["type"] }
    }
  }
}
