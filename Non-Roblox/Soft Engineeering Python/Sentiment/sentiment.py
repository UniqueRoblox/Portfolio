import math
from enum import Enum

class MenuOption(Enum):
    SHOW_REVIEWS = 'Show reviews'
    CHECK_TOKEN = 'Check if a token is present'
    SHOW_DOCUMENT_FREQUENCY = 'Show the document frequency for a particular token'
    SHOW_TOKEN_STATISTICS = 'Show all statistics for a particular token'
    SHOW_SENTENCE_STATISTICS = 'Show the statistics for a sentence'
    SAVE_STOP_WORD_LIST = 'Save the list of stop words to a file'
    SHOW_ADJUSTED_SENTENCE_STATISTICS = 'Show the statistics for a sentence with stop words ignored'
    EXIT = 'Exit the program'

def compute_adjusted_sentence_statistics(reviews, tokens, unique_tokens):
    sentence_selection = input('Enter a sentence as space-separated tokens: ')
    sentence_selection = sentence_selection.lower()
    token_list = sentence_selection.split()
    neutrals = 0
    positives = 0
    negatives = 0
    stop_words = 0
    total_positives = 0
    total_negatives = 0
    negative_classifications = 0
    positive_classifications = 0
    neutral_classifications = 0
    unknown_classifications = 0
    scores = []
    saved_words = compute_saved_words(tokens, unique_tokens)
    for element in reviews:
        element_split = element.split()
        if element_split[0] == '+':
            for i in element_split[1:]:
                total_positives += 1
        if element_split[0] == '-':
            for i in element_split[1:]:
                total_negatives += 1
    for token in token_list:
        if token in saved_words:
            stop_words += 1
        elif token in unique_tokens:
            for element in reviews:
                elements_split = element.split()
                if token in elements_split:
                    for i in elements_split:
                        if token == i:
                            if elements_split[0] == '+':
                                positives += 1
                            elif elements_split[0] == '-':
                                negatives += 1
                            elif elements_split[0] == '0':
                                neutrals += 1
            total = positives - negatives - 1
            if total < 0:
                negative_classifications += 1
            elif total > 0:
                positive_classifications += 1
            elif total == 0:
                neutral_classifications += 1
            score = (math.log(1 + positives) - math.log(1 + total_positives)) - (
                    math.log(1 + negatives) - math.log(1 + total_negatives))
            scores.append(score)
            positives = 0
            negatives = 0
            neutrals = 0
        else:
            unknown_classifications += 1
    if unknown_classifications + stop_words == len(token_list):
        print('The sentence contains only ' + str(stop_words) + ' stop word token(s) and ' +
              str(unknown_classifications) + ' unknown non-stop word token(s).')
        print('Therefore. its average tf-idf score is undefined')
    else:
        print('The sentence has ' + str(stop_words) + ' stop-word token(s), and it has ' +
              str(negative_classifications) + ' negative, ' + str(neutral_classifications) + ' neutral, '
                                                                                             'and ' + str(
            positive_classifications) + ' positive, and ' + str(unknown_classifications) + ' unknown token(s).')
        print('The sentence has an average tf-idf score of ' + str(find_average_tfidf_score(scores)))

    return negative_classifications, neutral_classifications, positive_classifications, unknown_classifications, find_average_tfidf_score(scores)




def write_output_file(tokens, unique_tokens):
    output = open("output.txt", 'w')
    saved_words = compute_saved_words(tokens, unique_tokens)
    for word in saved_words:
        output.write(word + '\n')
    print('Stop word list saved to \"output.txt\".')
    output.close()

    return saved_words


def compute_saved_words(tokens, unique_tokens):
    saved_words = []
    for token in unique_tokens:
        percent = tokens.count(token) / len(tokens)
        if percent >= 0.002:
            saved_words.append(token)
    saved_words = sorted(saved_words, key=lambda l: len(l))
    return saved_words


def compute_sentence_statistics(reviews, unique_tokens):
    sentence_selection = input('Enter a sentence as space-separated tokens: ')
    sentence_selection = sentence_selection.lower()
    token_list = sentence_selection.split()
    neutrals = 0
    positives = 0
    negatives = 0
    total_positives = 0
    total_negatives = 0
    negative_classifications = 0
    positive_classifications = 0
    neutral_classifications = 0
    unknown_classifications = 0
    scores = []
    for element in reviews:
        element_split = element.split()
        if element_split[0] == '+':
            for i in element_split[1:]:
                total_positives += 1
        if element_split[0] == '-':
            for i in element_split[1:]:
                total_negatives += 1
    for token in token_list:
        if token in unique_tokens:
            for element in reviews:
                elements_split = element.split()
                if token in elements_split:
                    for i in elements_split:
                        if token == i:
                            if elements_split[0] == '+':
                                positives += 1
                            elif elements_split[0] == '-':
                                negatives += 1
                            elif elements_split[0] == '0':
                                neutrals += 1
            total = positives - negatives - 1
            if total < 0:
                negative_classifications += 1
            elif total > 0:
                positive_classifications += 1
            elif total == 0:
                neutral_classifications += 1
            score = (math.log(1 + positives) - math.log(1 + total_positives)) - (
                    math.log(1 + negatives) - math.log(1 + total_negatives))
            scores.append(score)
            positives = 0
            negatives = 0
            neutrals = 0
        else:
            unknown_classifications += 1
    if unknown_classifications == len(token_list):
        print('The sentence contains only unknown tokens; therefore, its average tf-idf score is undefined.')
    else:
        print('The sentence has ' + str(negative_classifications) + ' negative, ' + str(
            neutral_classifications) + ' neutral, and ' + str(
            positive_classifications) + ' positive, and ' + str(unknown_classifications) + ' unknown token(s).')
        print('The sentence has an average tf-idf score of ' + str(find_average_tfidf_score(scores)))

    return negative_classifications, neutral_classifications, positive_classifications, unknown_classifications, find_average_tfidf_score(scores)

def find_average_tfidf_score(scores):
    scores_sum = 0
    for score in scores:
        scores_sum += score
    average_score = scores_sum / len(scores)
    return average_score


def get_token_statistics(reviews, unique_tokens):
    token_selection = input('Enter a token: ')
    token_selection = token_selection.lower()
    neutrals = 0
    positives = 0
    negatives = 0
    total_positives = 0
    total_negatives = 0
    if token_selection not in unique_tokens:
        print('The token \"' + token_selection + '\" does not appear in the training data.')
    else:
        for element in reviews:
            element_split = element.split()

            for i in element_split:
                if token_selection in element_split:
                    if token_selection == i:
                        if element_split[0] == '0':
                            neutrals += 1
                        elif element_split[0] == '+':
                            positives += 1
                        elif element_split[0] == '-':
                            negatives += 1
            if element_split[0] == '+':
                for i in element_split[1:]:
                    total_positives += 1
            if element_split[0] == '-':
                for i in element_split[1:]:
                    total_negatives += 1
        print('\'' + token_selection + '\' has ' + str(negatives) + ' negative, ' + str(
            neutrals) + ' neutral, and ' + str(positives) + ' positive appearance(s) in the training data.')
        score = (math.log(1 + positives) - math.log(1 + total_positives)) - (
                math.log(1 + negatives) - math.log(1 + total_negatives))
        classification = ''
        if score < 0:
            classification = 'negative'
        else:
            classification = 'positive'
        print(
            'The token \'' + token_selection + '\' is classified as ' + classification + ' because it has has a differential tf-idf score of ' + str(
                score))

        return negatives, neutrals, positives, score


def get_token_frequency(tokens):
    token_input = input('Enter a token: ')
    token_input = token_input.lower()
    print('The training data contains ' + str(
        tokens.count(token_input)) + ' appearances(s) of the token \'' + token_input + '\'')
    return tokens.count(token_input)


def check_if_token_present(tokens, unique_tokens):
    token_selection = input('Enter a token: ')
    token_selection = token_selection.lower()
    if token_selection in tokens:
        print('The token \'' + token_selection + '\' is one of the ' + str(
            len(unique_tokens)) + ' unique tokens that appear in the training data.')
    else:
        print('The token \'' + token_selection + '\' is not not one of the ' + str(
            len(unique_tokens)) + ' unique tokens that appear in the training data.')
    return len(unique_tokens)


def show_reviews(reviews):
    try:
        while True:
            first_review = input('Enter a beginning review number from 1 to 8529: ')
            last_review = input('Enter a beginning review number from ' + first_review + ' to 8529: ')
            if 1 <= int(first_review) <= 8529 and int(first_review) <= int(last_review) <= 8529:
                i = int(first_review) - 1
                while i < int(last_review):
                    print('Review #' + str(i + 1) + ': ' + reviews[i])
                    i += 1
                break
            else:
                print('Please enter a valid, in-range number for both review numbers')
    except TypeError:
        print('Please enter a number')


def main():
    answer1, answer2, answer3, answer4, answer5 = None, None, None, None, None
    element_split = []
    elements_list = []
    reviews = []
    unique_tokens = set()
    tokens = []
    try:
        sentiment = open("sentiment.txt")
        line = sentiment.readline()
        while not line == '':
            reviews.append(line.strip())
            line = sentiment.readline()
        for x in range(len(reviews)):
            element_list = reviews[x].split()
            element_list.pop(0)
            for y in element_list:
                unique_tokens.add(y)
        line = sentiment.readline()
        while not line == '':
            reviews.append(line.strip())
            line = sentiment.readline()
        for x in range(len(reviews)):
            elements_list = reviews[x].split()
            for y in elements_list:
                tokens.append(y)
    except NameError:
        print('Could not open file')
    options = tuple(MenuOption)
    while True:
        print('Choose an option:')
        number = 1
        for i in options:
            print(str(number) + '. ' + i.value)
            number += 1
        option_selection = 0
        while True:
            try:
                option_selection = int(input('Enter a number from 1 to 8:'))
            except ValueError:
                print('Invalid Error')
            if option_selection == 8:
                return answer1, answer2, answer3, answer4, answer5
            elif option_selection == 1:
                show_reviews(reviews)
                break
            elif option_selection == 2:
                answer1 = check_if_token_present(tokens, unique_tokens)
                break
            elif option_selection == 3:
                answer1 = get_token_frequency(tokens)
                break
            elif option_selection == 4:
                answer1, answer2, answer3, answer4 = get_token_statistics(reviews, unique_tokens)
                break
            elif option_selection == 5:
                answer1, answer2, answer3, answer4, answer5 = compute_sentence_statistics(reviews, unique_tokens)
                break
            elif option_selection == 6:
                answer1 = len(write_output_file(tokens, unique_tokens))
                break
            elif option_selection == 7:
                answer1, answer2, answer3, answer4, answer5 = compute_adjusted_sentence_statistics(reviews, tokens, unique_tokens)
                break

            else:
                print('Please enter a valid, in-range number.')


if __name__ == '__main__':
    main()
