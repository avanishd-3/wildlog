// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public struct ParkFiltersInput: InputObject {
  @_spi(Unsafe) public private(set) var __data: InputDict

  @_spi(Unsafe) public init(_ data: InputDict) {
    __data = data
  }

  public init(
    cost: GraphQLNullable<GraphQLEnum<ParkCostFilterEnum>> = nil,
    search: GraphQLNullable<String> = nil,
    type: GraphQLNullable<GraphQLEnum<ParkTypeEnum>> = nil
  ) {
    __data = InputDict([
      "cost": cost,
      "search": search,
      "type": type
    ])
  }

  public var cost: GraphQLNullable<GraphQLEnum<ParkCostFilterEnum>> {
    get { __data["cost"] }
    set { __data["cost"] = newValue }
  }

  public var search: GraphQLNullable<String> {
    get { __data["search"] }
    set { __data["search"] = newValue }
  }

  public var type: GraphQLNullable<GraphQLEnum<ParkTypeEnum>> {
    get { __data["type"] }
    set { __data["type"] = newValue }
  }
}
