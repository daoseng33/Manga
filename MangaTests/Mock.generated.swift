// Generated using Sourcery 1.0.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT



// Generated with SwiftyMocky 4.0.1

import SwiftyMocky
import XCTest
import Foundation
@testable import Manga


// MARK: - FavoriteItemServiceProtocol

open class FavoriteItemServiceProtocolMock: FavoriteItemServiceProtocol, Mock {
    public init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }





    open func isItemLike(with malId: Int) -> Bool {
        addInvocation(.m_isItemLike__with_malId(Parameter<Int>.value(`malId`)))
		let perform = methodPerformValue(.m_isItemLike__with_malId(Parameter<Int>.value(`malId`))) as? (Int) -> Void
		perform?(`malId`)
		var __value: Bool
		do {
		    __value = try methodReturnValue(.m_isItemLike__with_malId(Parameter<Int>.value(`malId`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for isItemLike(with malId: Int). Use given")
			Failure("Stub return value not specified for isItemLike(with malId: Int). Use given")
		}
		return __value
    }

    open func addItemToFavoriteList(with topItem: TopItem) {
        addInvocation(.m_addItemToFavoriteList__with_topItem(Parameter<TopItem>.value(`topItem`)))
		let perform = methodPerformValue(.m_addItemToFavoriteList__with_topItem(Parameter<TopItem>.value(`topItem`))) as? (TopItem) -> Void
		perform?(`topItem`)
    }

    open func deleteItemFromFavoriteList(with malId: Int) {
        addInvocation(.m_deleteItemFromFavoriteList__with_malId(Parameter<Int>.value(`malId`)))
		let perform = methodPerformValue(.m_deleteItemFromFavoriteList__with_malId(Parameter<Int>.value(`malId`))) as? (Int) -> Void
		perform?(`malId`)
    }


    fileprivate enum MethodType {
        case m_isItemLike__with_malId(Parameter<Int>)
        case m_addItemToFavoriteList__with_topItem(Parameter<TopItem>)
        case m_deleteItemFromFavoriteList__with_malId(Parameter<Int>)

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Matcher.ComparisonResult {
            switch (lhs, rhs) {
            case (.m_isItemLike__with_malId(let lhsMalid), .m_isItemLike__with_malId(let rhsMalid)):
				var results: [Matcher.ParameterComparisonResult] = []
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsMalid, rhs: rhsMalid, with: matcher), lhsMalid, rhsMalid, "with malId"))
				return Matcher.ComparisonResult(results)

            case (.m_addItemToFavoriteList__with_topItem(let lhsTopitem), .m_addItemToFavoriteList__with_topItem(let rhsTopitem)):
				var results: [Matcher.ParameterComparisonResult] = []
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsTopitem, rhs: rhsTopitem, with: matcher), lhsTopitem, rhsTopitem, "with topItem"))
				return Matcher.ComparisonResult(results)

            case (.m_deleteItemFromFavoriteList__with_malId(let lhsMalid), .m_deleteItemFromFavoriteList__with_malId(let rhsMalid)):
				var results: [Matcher.ParameterComparisonResult] = []
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsMalid, rhs: rhsMalid, with: matcher), lhsMalid, rhsMalid, "with malId"))
				return Matcher.ComparisonResult(results)
            default: return .none
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_isItemLike__with_malId(p0): return p0.intValue
            case let .m_addItemToFavoriteList__with_topItem(p0): return p0.intValue
            case let .m_deleteItemFromFavoriteList__with_malId(p0): return p0.intValue
            }
        }
        func assertionName() -> String {
            switch self {
            case .m_isItemLike__with_malId: return ".isItemLike(with:)"
            case .m_addItemToFavoriteList__with_topItem: return ".addItemToFavoriteList(with:)"
            case .m_deleteItemFromFavoriteList__with_malId: return ".deleteItemFromFavoriteList(with:)"
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }


        public static func isItemLike(with malId: Parameter<Int>, willReturn: Bool...) -> MethodStub {
            return Given(method: .m_isItemLike__with_malId(`malId`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func isItemLike(with malId: Parameter<Int>, willProduce: (Stubber<Bool>) -> Void) -> MethodStub {
            let willReturn: [Bool] = []
			let given: Given = { return Given(method: .m_isItemLike__with_malId(`malId`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (Bool).self)
			willProduce(stubber)
			return given
        }
    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func isItemLike(with malId: Parameter<Int>) -> Verify { return Verify(method: .m_isItemLike__with_malId(`malId`))}
        public static func addItemToFavoriteList(with topItem: Parameter<TopItem>) -> Verify { return Verify(method: .m_addItemToFavoriteList__with_topItem(`topItem`))}
        public static func deleteItemFromFavoriteList(with malId: Parameter<Int>) -> Verify { return Verify(method: .m_deleteItemFromFavoriteList__with_malId(`malId`))}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func isItemLike(with malId: Parameter<Int>, perform: @escaping (Int) -> Void) -> Perform {
            return Perform(method: .m_isItemLike__with_malId(`malId`), performs: perform)
        }
        public static func addItemToFavoriteList(with topItem: Parameter<TopItem>, perform: @escaping (TopItem) -> Void) -> Perform {
            return Perform(method: .m_addItemToFavoriteList__with_topItem(`topItem`), performs: perform)
        }
        public static func deleteItemFromFavoriteList(with malId: Parameter<Int>, perform: @escaping (Int) -> Void) -> Perform {
            return Perform(method: .m_deleteItemFromFavoriteList__with_malId(`malId`), performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let fullMatches = matchingCalls(method, file: file, line: line)
        let success = count.matches(fullMatches)
        let assertionName = method.method.assertionName()
        let feedback: String = {
            guard !success else { return "" }
            return Utils.closestCallsMessage(
                for: self.invocations.map { invocation in
                    matcher.set(file: file, line: line)
                    defer { matcher.clearFileAndLine() }
                    return MethodType.compareParameters(lhs: invocation, rhs: method.method, matcher: matcher)
                },
                name: assertionName
            )
        }()
        MockyAssert(success, "Expected: \(count) invocations of `\(assertionName)`, but was: \(fullMatches).\(feedback)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        invocations.append(call)
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType, file: StaticString?, line: UInt?) -> [MethodType] {
        matcher.set(file: file ?? self.file, line: line ?? self.line)
        defer { matcher.clearFileAndLine() }
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher).isFullMatch }
    }
    private func matchingCalls(_ method: Verify, file: StaticString?, line: UInt?) -> Int {
        return matchingCalls(method.method, file: file, line: line).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleFatalError(message: message, file: file, line: line)
    }
}

