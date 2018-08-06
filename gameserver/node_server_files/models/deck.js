class Deck {

	constructor(id){
		this.cards = [0, 0, 0, 1, 1, 2, 3, 3]
		this.shuffle();
	}

	deckCount(){
		return this.cards.length;
	}

	cardsLeft() {
		return this.cards.slice(); //return a clone
	}

	shuffle() {
	    for (let i = this.cards.length - 1; i > 0; i--) {
	        const j = Math.floor(Math.random() * (i + 1));
	        [this.cards[i], this.cards[j]] = [this.cards[j], this.cards[i]];
	    }
	}

	removeFromTop(){
		return this.cards.shift();
	}

	removeFromBottom(){
		return this.cards.pop();
	}

	isEmpty(){
		return this.cards.length == 0;
	}
}

module.exports = Deck