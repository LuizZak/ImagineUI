@resultBuilder
public struct LayoutResultBuilder {
    public static func buildExpression(_ expression: LayoutConstraintDefinition) -> LayoutConstraintDefinitions {
        return .init(definitions: [expression])
    }

    public static func buildExpression(_ expression: LayoutConstraintDefinitions) -> LayoutConstraintDefinitions {
        return expression
    }

    public static func buildExpression(_ expression: LayoutConstraintDefinitions...) -> LayoutConstraintDefinitions {
        return .init(definitions: expression.flatMap(\.definitions))
    }

    public static func buildEither(first component: LayoutConstraintDefinitions) -> LayoutConstraintDefinitions {
        return component
    }

    public static func buildEither(second component: LayoutConstraintDefinitions) -> LayoutConstraintDefinitions {
        return component
    }

    public static func buildOptional(_ component: LayoutConstraintDefinitions?) -> LayoutConstraintDefinitions {
        if let component = component {
            return component
        }

        return .init(definitions: [])
    }

    public static func buildBlock() -> LayoutConstraintDefinitions {
        return .init(definitions: [])
    }

    public static func buildBlock(_ components: LayoutConstraintDefinition...) -> LayoutConstraintDefinitions {
        return .init(definitions: components)
    }

    public static func buildBlock(_ components: LayoutConstraintDefinitions...) -> LayoutConstraintDefinitions {
        return .init(definitions: components.flatMap(\.definitions))
    }

    public static func buildFinalResult(_ component: LayoutConstraintDefinitions) -> LayoutConstraintDefinitions {
        return component
    }
}
