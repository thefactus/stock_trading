# Stock Trading API

A simple stock trading API that allows buyers to view businesses, view business purchases,
and place buy orders. Business owners can view their business, view buy orders, and accept or reject them.

**Deployed on Heroku:** [Stock Trading API](https://stocktradingapi-2b9b63ae350d.herokuapp.com/)

The root URL is a Swagger UI interface for the API that allows you to interact with the endpoints. Please use it to test the API.

**Rubycritic score:** 95.82 (app folder) 19 files A, 2 files B

**Simplecov coverage:** 97.83% (585 / 598)

### Strategy

- I decided to start the project by first designing the API with a OpenAPI document. Utilising the [documentation-first approach](https://evilmartians.com/chronicles/let-there-be-docs-a-documentation-first-approach-to-rails-api-development).
  - I didn't use rswag to not use a DSL and to allow the project to be more flexible.
  - I used Skooma to validate the API against the OpenAPI document.
    - It means that the API is always in sync with the documentation through the tests.
- The API allows buyers to view businesses, view business purchases, and place buy orders.
- Business owners can view their business, view buy orders and accept or reject them.
- There is no wallet or money system, because that would add extra layers of complexity.
- I decided to separate the endpoint into namespaces for buyers and owners to make it easier to manage.
- I used the **principle of least privilege** to handle authorization.
- Used the services folder to handle business logic.
- Buyers can create a buy_order with the business_id, quantity, and price.
- Owners can accept or reject a buy_order.
- When a buy_order is accepted, the business owner creates a purchase. Also updating the business shares.

##### What would be required if we allowed for multiple currencies? The business shares would be in either GBP or EUR. How could the buyer pay for the shares? A wallet representing each currency? A single wallet? Currency conversion? How could be some of the pitfalls if the business owner rejected the purchase?

To support multiple currencies like GBP and EUR, I would implement a wallet that holds separate balances for each currency within a single wallet associated with the user. For each transaction, I would use rate-locking mechanisms to fix exchange rates at the time of purchase, ensuring consistent refund amounts if the business owner rejects the purchase. Integrating with reliable currency exchange rate APIs would provide real-time rates. Atomic transactions would guarantee that all related operations succeed or fail together. Here's an example of how the wallet could be implemented:

```ruby
class Wallet < ApplicationRecord
  belongs_to :user
  has_many :transactions
  has_many :wallet_balances
end

class WalletBalance < ApplicationRecord
  belongs_to :wallet
  validates :currency, inclusion: { in: %w[GBP EUR] }
  validates :balance, numericality: { greater_than_or_equal_to: 0 }
end
```

##### Imagine a business’s shares are going on sale at a specific date and time and demand is expected to outstrip supply. What would be required to scale this to handle high demand in a short time frame? How could we limit the number of shares per buyer to make sure one buyer wasn’t able to buy them all?

To handle high demand during a share sale, I would scale the infrastructure using load balancers and auto-scaling to manage increased traffic. To prevent one buyer from purchasing all shares, I’d enforce per-buyer purchase limits through validations.

### API Structure

The Stock Trading API is organized into the following categories, each handling specific functionalities:

#### Buyers - Businesses

- **GET `/buyers/businesses`**
  - _Description:_ List all businesses with available shares.
- **GET `/buyers/businesses/{businessId}/purchases`**
  - _Description:_ View historical purchases of a specific business.

#### Buyers - BuyOrders

- **POST `/buyers/businesses/{businessId}/buy_orders`**
  - _Description:_ Place a new buy order for a business.

#### Owners - Businesses

- **GET `/owners/businesses`**
  - _Description:_ Retrieve all businesses owned by the authenticated owner.

#### Owners - BuyOrders

- **GET `/owners/businesses/{businessId}/buy_orders`**
  - _Description:_ List buy orders for a specific business.
- **PATCH `/owners/businesses/{businessId}/buy_orders/{buyOrderId}`**
  - _Description:_ Accept or reject a buy order.

#### Authentication

- **POST `/users`**
  - _Description:_ Register a new user account.

**Authentication:** All endpoints require Basic Auth except for user registration (`POST /users`).

**Responses:** Common response codes include `200 OK`, `201 Created`, `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, and `422 Unprocessable Entity`.

**Schemas:** The API utilizes schemas like `Business`, `Purchase`, `BuyOrder`, `NewBuyOrder`, `UpdateBuyOrder`, `NewUser`, and `Error` for structured data exchange.

### Technologies

- Ruby on Rails API only, version 8.0.0
- Ruby version 3.3.6
- PostgreSQL for the database
- Heroku for deployment
- GitHub Actions for continuous integration
- OpenAPI for API documentation (Swagger UI)
- Skooma (Skooma is a Ruby library for validating API implementations against OpenAPI documents)
- Spectral for linting OpenAPI documents
- Rubocop for linting (40 files inspected, no offenses detected)
- Devise for user authentication (Basic Auth)
- Pundit for authorization
- RSpec for testing (55 tests)
- Shoulda Matchers
- FactoryBot for test data
- Faker for generating fake data
- Developed using NeoVim (LazyVim)

## Development process

- Started by analyzing the requirements and planning key features and models
- Created the project with Ruby 3.3.6, Rails 8.0.0, PostgreSQL, and RSpec
- Added the openapi.yml file for API documentation
- Integrated Rubocop for linting and maintained high code quality
- Implemented Devise for HTTP basic authentication and Pundit for authorization
- Set up PostgreSQL and added UUIDs with pgcrypto
- Created the Business, Buyer, and BuyOrder models
- Added seed data for businesses
- Built API endpoints for listing businesses, placing buy orders, and managing orders
- Added functionality for buyers to view historical purchases and place orders
- Implemented functionality for business owners to accept or reject orders
- Set up GitHub Actions for continuous integration
- Wrote unit and integration tests using RSpec, FactoryBot, and Shoulda Matchers
- Deployed the project to Heroku
- Added a README for project setup and usage

## Improvements to be made

- I decided to not add separate serializers because it would take longer to implement and test. I would add serializers if the project was larger and had more complex relationships.
- Add tests for each service. The services are currently tested through the controllers, but it would be better to have separate tests for each service. I didn't add them because it would take longer to finish the task.
- Achieve 100% test coverage. The current test coverage is 97.93%.

## Setup

To run the Stock Trading API locally, follow these steps:

Clone the repository

Install dependencies:

    bundle

Set up the database:

    rails db:setup

Start the server:

    rails s

Access the API at `http://localhost:3000`
It gives you the API documentation and you can test the API endpoints.

### Prerequisites

Ruby version 3.3.6 is required
Bundler for managing gem dependencies
PostgreSQL installed and running

**Checking and Installing Ruby**

First, check if you have the required Ruby version installed:

    ruby -v

1. Install rbenv and ruby-build:

```sh
# macOS
brew install rbenv

# Ubuntu
sudo apt-get install rbenv

# Add rbenv to bashrc
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL

# or to zshrc
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init -)"' >> ~/.zshrc
source ~/.zshrc
```

2. Install ruby-build:

```sh
# macOS
brew install ruby-build
brew upgrade ruby-build

# Ubuntu
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
git -C "$(rbenv root)"/plugins/ruby-build pull
```

3. Install Ruby:

```sh
rbenv install 3.3.6
```

4. Set the global version of Ruby:

```sh
rbenv global 3.3.6
```

5. Verify that Ruby was installed correctly:

```sh
ruby -v # You should see ruby 3.3.6
```
