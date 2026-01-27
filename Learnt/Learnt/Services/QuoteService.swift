//
//  QuoteService.swift
//  Learnt

import Foundation

struct Quote: Identifiable {
    let id = UUID()
    let text: String
    let author: String
}

@Observable
final class QuoteService {
    static let shared = QuoteService()

    private let hiddenDateKey = "QuoteHiddenDate"

    private let quotes: [Quote] = [
        // Stoics
        Quote(text: "The obstacle is the way.", author: "Marcus Aurelius"),
        Quote(text: "We suffer more in imagination than in reality.", author: "Seneca"),
        Quote(text: "It is not that we have a short time to live, but that we waste a lot of it.", author: "Seneca"),
        Quote(text: "Man is not worried by real problems so much as by his imagined anxieties about real problems.", author: "Epictetus"),
        Quote(text: "No man is free who is not master of himself.", author: "Epictetus"),
        Quote(text: "The best revenge is not to be like your enemy.", author: "Marcus Aurelius"),
        Quote(text: "You have power over your mind - not outside events. Realize this, and you will find strength.", author: "Marcus Aurelius"),
        Quote(text: "Waste no more time arguing about what a good man should be. Be one.", author: "Marcus Aurelius"),
        Quote(text: "If it is not right, do not do it. If it is not true, do not say it.", author: "Marcus Aurelius"),
        Quote(text: "How long are you going to wait before you demand the best for yourself?", author: "Epictetus"),
        Quote(text: "Difficulties strengthen the mind, as labor does the body.", author: "Seneca"),
        Quote(text: "He who fears death will never do anything worth of a man who is alive.", author: "Seneca"),
        Quote(text: "Begin at once to live, and count each separate day as a separate life.", author: "Seneca"),
        Quote(text: "True happiness is to enjoy the present, without anxious dependence upon the future.", author: "Seneca"),
        Quote(text: "Luck is what happens when preparation meets opportunity.", author: "Seneca"),
        Quote(text: "First say to yourself what you would be; and then do what you have to do.", author: "Epictetus"),
        Quote(text: "Circumstances don't make the man, they only reveal him to himself.", author: "Epictetus"),
        Quote(text: "The key is to keep company only with people who uplift you.", author: "Epictetus"),
        Quote(text: "Dwell on the beauty of life. Watch the stars, and see yourself running with them.", author: "Marcus Aurelius"),
        Quote(text: "Very little is needed to make a happy life; it is all within yourself.", author: "Marcus Aurelius"),

        // Philosophers
        Quote(text: "The unexamined life is not worth living.", author: "Socrates"),
        Quote(text: "I know that I know nothing.", author: "Socrates"),
        Quote(text: "We are what we repeatedly do. Excellence, then, is not an act, but a habit.", author: "Aristotle"),
        Quote(text: "Knowing yourself is the beginning of all wisdom.", author: "Aristotle"),
        Quote(text: "It is the mark of an educated mind to be able to entertain a thought without accepting it.", author: "Aristotle"),
        Quote(text: "The only true wisdom is in knowing you know nothing.", author: "Socrates"),
        Quote(text: "He who has a why to live can bear almost any how.", author: "Friedrich Nietzsche"),
        Quote(text: "That which does not kill us makes us stronger.", author: "Friedrich Nietzsche"),
        Quote(text: "Life must be understood backward. But it must be lived forward.", author: "Soren Kierkegaard"),
        Quote(text: "The mind is everything. What you think you become.", author: "Buddha"),
        Quote(text: "Peace comes from within. Do not seek it without.", author: "Buddha"),
        Quote(text: "In the middle of difficulty lies opportunity.", author: "Albert Einstein"),
        Quote(text: "The measure of intelligence is the ability to change.", author: "Albert Einstein"),
        Quote(text: "Simplicity is the ultimate sophistication.", author: "Leonardo da Vinci"),
        Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
        Quote(text: "Stay hungry, stay foolish.", author: "Steve Jobs"),

        // Writers & Thinkers
        Quote(text: "The only thing we have to fear is fear itself.", author: "Franklin D. Roosevelt"),
        Quote(text: "In three words I can sum up everything I've learned about life: it goes on.", author: "Robert Frost"),
        Quote(text: "The purpose of life is a life of purpose.", author: "Robert Byrne"),
        Quote(text: "Do what you can, with what you have, where you are.", author: "Theodore Roosevelt"),
        Quote(text: "It is during our darkest moments that we must focus to see the light.", author: "Aristotle"),
        Quote(text: "What lies behind us and what lies before us are tiny matters compared to what lies within us.", author: "Ralph Waldo Emerson"),
        Quote(text: "To be yourself in a world that is constantly trying to make you something else is the greatest accomplishment.", author: "Ralph Waldo Emerson"),
        Quote(text: "The two most important days in your life are the day you are born and the day you find out why.", author: "Mark Twain"),
        Quote(text: "Twenty years from now you will be more disappointed by the things you didn't do than by the ones you did.", author: "Mark Twain"),
        Quote(text: "I have not failed. I've just found 10,000 ways that won't work.", author: "Thomas Edison"),
        Quote(text: "The secret of getting ahead is getting started.", author: "Mark Twain"),
        Quote(text: "Be the change you wish to see in the world.", author: "Mahatma Gandhi"),
        Quote(text: "Live as if you were to die tomorrow. Learn as if you were to live forever.", author: "Mahatma Gandhi"),
        Quote(text: "The best time to plant a tree was 20 years ago. The second best time is now.", author: "Chinese Proverb"),
        Quote(text: "A journey of a thousand miles begins with a single step.", author: "Lao Tzu"),
        Quote(text: "The way to get started is to quit talking and begin doing.", author: "Walt Disney"),
        Quote(text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius"),
        Quote(text: "Our greatest glory is not in never falling, but in rising every time we fall.", author: "Confucius"),
        Quote(text: "Education is not the filling of a pail, but the lighting of a fire.", author: "W.B. Yeats"),
        Quote(text: "The only impossible journey is the one you never begin.", author: "Tony Robbins"),

        // Modern Wisdom
        Quote(text: "Done is better than perfect.", author: "Sheryl Sandberg"),
        Quote(text: "If you want to lift yourself up, lift up someone else.", author: "Booker T. Washington"),
        Quote(text: "The best preparation for tomorrow is doing your best today.", author: "H. Jackson Brown Jr."),
        Quote(text: "Success is not final, failure is not fatal: it is the courage to continue that counts.", author: "Winston Churchill"),
        Quote(text: "We make a living by what we get, but we make a life by what we give.", author: "Winston Churchill"),
        Quote(text: "The only limit to our realization of tomorrow is our doubts of today.", author: "Franklin D. Roosevelt"),
        Quote(text: "You miss 100% of the shots you don't take.", author: "Wayne Gretzky"),
        Quote(text: "Whether you think you can or you think you can't, you're right.", author: "Henry Ford"),
        Quote(text: "Quality means doing it right when no one is looking.", author: "Henry Ford"),
        Quote(text: "The harder I work, the luckier I get.", author: "Gary Player"),
        Quote(text: "Every moment is a fresh beginning.", author: "T.S. Eliot"),
        Quote(text: "What we think, we become.", author: "Buddha"),
        Quote(text: "The only person you are destined to become is the person you decide to be.", author: "Ralph Waldo Emerson"),
        Quote(text: "Act as if what you do makes a difference. It does.", author: "William James"),
        Quote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt"),
        Quote(text: "Keep your face always toward the sunshine and shadows will fall behind you.", author: "Walt Whitman"),
        Quote(text: "It is never too late to be what you might have been.", author: "George Eliot"),
        Quote(text: "Everything you've ever wanted is on the other side of fear.", author: "George Addair"),
        Quote(text: "Start where you are. Use what you have. Do what you can.", author: "Arthur Ashe"),
        Quote(text: "The mind that opens to a new idea never returns to its original size.", author: "Albert Einstein"),
    ]

    var quoteOfTheDay: Quote {
        quote(for: Date())
    }

    /// Returns the quote for a specific date (deterministic based on day of year)
    func quote(for date: Date) -> Quote {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = (dayOfYear - 1) % quotes.count
        return quotes[index]
    }

    /// Returns quotes for the previous 7 days (not including today)
    var previousQuotes: [(date: Date, quote: Quote)] {
        (1...7).compactMap { daysAgo in
            guard let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) else {
                return nil
            }
            return (date, quote(for: date))
        }
    }

    var isQuoteHidden: Bool {
        guard let hiddenDateString = UserDefaults.standard.string(forKey: hiddenDateKey),
              let hiddenDate = ISO8601DateFormatter().date(from: hiddenDateString) else {
            return false
        }
        return hiddenDate.isSameDay(as: Date())
    }

    func hideQuoteForToday() {
        let formatter = ISO8601DateFormatter()
        UserDefaults.standard.set(formatter.string(from: Date()), forKey: hiddenDateKey)
    }

    func showQuote() {
        UserDefaults.standard.removeObject(forKey: hiddenDateKey)
    }
}
