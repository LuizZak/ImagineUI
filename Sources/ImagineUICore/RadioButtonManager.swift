/// A protocol to be implemented by objects that manage the selection state of
/// radio buttons.
public protocol RadioButtonManagerType {
    /// Requests that the given radio button be selected, de-selecting any
    /// currently active radio buttons at the same level.
    func selectRadioButton(_ radioButton: RadioButton)
}

extension RadioButtonManagerType where Self: View {
    public func selectRadioButton(_ radioButton: RadioButton) {
        iterateRadioButtonSubviews { button in
            guard button.isSelected else {
                return true
            }
            
            if button != radioButton {
                button.isSelected = false
                radioButton.isSelected = true
            }
            
            return false
        }
    }
    
    private func iterateRadioButtonSubviews(_ iterator: (RadioButton) -> Bool) {
        var queue: [View] = subviews
        
        while !queue.isEmpty {
            let next = queue.remove(at: 0)
            
            if next is RadioButtonManagerType {
                continue
            }
            
            if let radio = next as? RadioButton, radio.radioButtonManager == nil || radio.radioButtonManager as? View == self {
                if !iterator(radio) {
                    return
                }
            }
            
            queue.append(contentsOf: next.subviews)
        }
    }
}
