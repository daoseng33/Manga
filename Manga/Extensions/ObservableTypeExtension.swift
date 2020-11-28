//
//  ObserverTypeExtension.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/29.
//

import RxSwift

extension ObservableType {
  func previous(startWith first: Element) -> Observable<(Element, Element)> {
    return scan((first, first)) { ($0.1, $1) }.skip(1)
  }
}
