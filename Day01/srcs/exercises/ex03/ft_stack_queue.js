/**
 * @param {Array} items
 * @returns {void}
 */

function ft_stack_queue(items) {
    let copy = [...items] // Les 3 points (...) copient les ÉLÉMENTS de items
    
    copy.push("nano")
    console.log("After .push() : ",copy)
    copy.pop()
    console.log("After .pop() : ",copy)
    copy.unshift("hello")
    console.log("After .unshift() : ",copy)
    copy.shift()
    console.log("After .shift() : ",copy)
}

// ft_stack_queue(['ayoub', 'learn', 'java-script', 'course'])

module.exports = ft_stack_queue