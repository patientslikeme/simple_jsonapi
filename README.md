# SimpleJsonapi

A library for building [JSONAPI](http://jsonapi.org) documents in Ruby. You may also be interested in [simple\_jsonapi\_rails](../simple_jsonapi_rails/README.md), which provides some integrations for using simple_jsonapi in a Rails application.

To view this README and more documentation of specific classes and methods, view the YARD documentation by running `yard server --reload` and visiting http://localhost:8808.

### Features

SimpleJsonapi supports the following JSONAPI features:

* Singular and collection endpoints
* Attributes and relationships, including nested relationships
* Sparse fieldsets (**fields** parameter)
* Inclusion of related resources (**include** parameter & **included** member)
* Links and meta information on the document root, resources, and relationships
* Error objects (**errors** member)

Other features include:

* Serializers that are easy to define
* Sorting of first-level relationships (**sort_related** parameter)

## What is JSONAPI?

A specification for building APIs in JSON. As its creators [write](http://jsonapi.org):

> If you’ve ever argued with your team about the way your JSON responses should be formatted, JSON API can be your anti-bikeshedding tool.

Here's a sample JSONAPI response that also sets the stage for the examples we'll see below:

```json
{
  "data": [{
    "type": "orders",
    "id": "1",
    "attributes": {
      "order_date": "2017-10-15",
      "ship_date": null,
      "customer_reference": "ABC123"
    },
    "relationships": {
      "customer": {
        "data": { "type": "customers", "id": "33" },
        "links": {
          "self": "http://example.com/orders/1/relationships/customer",
          "related": "http://example.com/orders/1/customer"
        },
        "meta": { "included": true }
      },
      "products": {
        "data": [
          { "type": "products", "id": "7" },
          { "type": "products", "id": "19" }
        ],
        "links": {
          "self": "http://example.com/orders/1/relationships/products",
          "related": "http://example.com/orders/1/products"
        },
        "meta": { "included": true }
      }
    },
    "links": {
      "self": "http://example.com/orders/1"
    }
  }],
  "included": [{
    "type": "customers",
    "id": "33",
    "attributes": {
      "first_name": "Jane",
      "last_name": "Doe"
    },
    "links": {
      "self": "http://example.com/customers/33"
    }
  }, {
    "type": "products",
    "id": "7",
    "attributes": {
      "name": "Widget"
    },
    "links": {
      "self": "http://example.com/products/7"
    }
  }, {
    "type": "products",
    "id": "19",
    "attributes": {
      "name": "Gadget"
    },
    "links": {
      "self": "http://example.com/products/19"
    }
  }],
  "links": {
    "self": "http://example.com/orders",
    "next": "http://example.com/orders?page[number]=2",
    "last": "http://example.com/orders?page[number]=10"
  },
  "meta": {
    "generated_at": "2017-11-01T12:34:56Z"
  }
}
```

## Installation

If you're using Bundler, just add SimpleJsonapi to your Gemfile:

```
gem 'simple_jsonapi'
```

Or run `gem install simple_jsonapi` and then add `require 'simple_jsonapi'` to your code.

## Basic usage

Suppose we have these resource classes.

```ruby
class Order
  include ActiveModel::Model  # for the intializer
  attr_accessor :id, :order_date, :ship_date, :customer_reference, :customer, :products
end

class Customer
  include ActiveModel::Model
  attr_accessor :id, :first_name, :last_name
end

class Product
  include ActiveModel::Model
  attr_accessor :id, :name
end
```

First we define a serializer for each class.

```ruby
class OrderSerializer < SimpleJsonapi::Serializer
  # `type` and `id` can be inferred from the class name and its `id` method

  attributes :order_date, :ship_date, :customer_reference

  has_one :customer, serializer: CustomerSerializer
  has_many :products, serializer: ProductSerializer do
    data { |order| order.products.sort_by(&:name) }
  end

  link(:self) { |order| "http://example.com/orders/#{order.id}" }
end

class CustomerSerializer < SimpleJsonapi::Serializer
  attributes :first_name, :last_name
end

class ProductSerializer < SimpleJsonapi::Serializer
  attributes :name
end
```

Then we can call `SimpleJsonapi.render_resource` to render a single resource.

```ruby
> order = Order.new(id: 1, order_date: Date.new(2017, 10, 15), customer_reference: "ABC123")

> SimpleJsonapi.render_resource(order)
{
  :data => {
    :id => "1",
    :type => "orders",
    :attributes => {
      :order_date => Sun, 15 Oct 2017,
      :ship_date => nil,
      :customer_reference => "ABC123"
    }
  }
}
```

And we can call `SimpleJsonapi.render_resources` to render a collection of resources. `render_resources` accepts either a single resource or an `Enumerable` and always renders an array.

```ruby
> SimpleJsonapi.render_resources([order1, order2])
{
  :data => [
    {
      :id => "1",
      :type => "orders",
      :attributes => { ... }
    }, {
      :id => "1",
      :type => "orders",
      :attributes => { ... }
    }
  ]
}
```

Finally, we can call `SimpleJsonapi.render_errors` to render a document with an `errors` member. Like `render_resources`, `render_errors` accepts either a single error or an `Enumerable` and always renders an array.

```ruby
> error = StandardError.new("something wicked this way comes")

> SimpleJsonapi.render_errors(error)
{
  :errors => [
    {
      :code => "standard_error",
      :title => "StandardError",
      :detail => "something wicked this way comes"
    }
  ]
}
```

## Advanced usage

### Type and ID

The **type** member is inferred from the resource's class name. For example, an `Ordering::LineItem` instance's **type** would be `"line_items"`. A serializer can generate a different **type** by providing a value or a block.

```ruby
class LineItemSerializer < SimpleJsonapi::Serializer
  type "entries"
  # or
  type { |item| item.class.name.underscore }
end
```

The **id** member calls the resource's `id` method. A serializer can override the **id** by providing a value or a block.

```ruby
class OrderSerializer < SimpleJsonapi::Serializer
  id "3.14"
  # or
  id { |item| item.order_id }
end
```

### Attributes

By default, attributes call the method of the same name on the resource. Serializers can provide custom implementations as well.

```ruby
class OrderSerializer < SimpleJsonapi::Serializer
  attribute :system_version, "1.0"
  attribute(:order_date) { |order| order.created_at.to_date }
end
```

Attributes (and relationships) can be conditionally rendered by providing an `if` or `unless` parameter. (`@current_user` is discussed below)

```ruby
class UserSerializer < SimpleJsonapi::Serializer
  attribute :ssn, if: { @current_user.is_an_admin? }
  attribute :country, unless: { |user| user.hide_demographics? }
end
```

Resources can have **links** and **meta** information.

```ruby
class OrderSerializer < SimpleJsonapi::Serializer
  attributes :order_date, :ship_date, :customer_reference

  link(:self) { |order| "https://example.com/orders/#{order.id}" }

  meta(:last_refreshed) { |order| order.updated_at }
end
```

### Relationships

Relationships are defined with `has_one` and `has_many`; both take the same parameters.

By default, the related resources are retrieved by calling the method of the same name on the resource. Serializers can provide custom implementations as well.

```ruby
class OrderSerializer < SimpleJsonapi::Serializer
  has_one :customer  # calls `order.customer`

  has_many :products do
    data { |order| order.products.sort_by(&:name) }
  end
end
```

By default, a serializer is chosen based on the class of the related resource. Relationships can also specify a serializer to use, or a `SerializerInferrer` that will choose an appropriate serializer for ach resource.

```ruby
class OrderSerializer < SimpleJsonapi::Serializer
  has_one :customer, serializer: CustomerSerializer
  has_many :products, serializer: ORDERING_SERIALIZER_INFERRER
end

ORDERING_SERIALIZER_INFERRER = SimpleJsonapi::SerializerInferrer.new do |resource|
  "Serializers::#{resource.class.name}".safe_constantize
end
```

Like resources, relationships can have **links** and **meta** information.

```ruby
class OrderSerializer < SimpleJsonapi::Serializer
  has_many :products do
    link(:self) { |order| "https://example.com/orders/#{order.id}/relationship/products" }
    link(:related) { |order| "https://example.com/orders/#{order.id}/products" }

    meta(:sorted_by) { "product_name" }
  end
end
```

Relationships can be conditionally rendered; see the discussion of `if` and `unless` above under "Attributes".

### Sparse fieldsets

The `render_resource` and `render_resources` methods accept a `fields` parameter to filter the list of fields in the rendered resources. The parameter is a hash with object **type**s as keys and comma-delimited lists or arrays of fields as values.

```ruby
> SimpleJsonapi.render_resource(order,
  include: "customer",
  fields: {
    orders: "order_date,ship_date,customer",
    customers: ["last_name", "first_name"],
  }
))
```

Note that if you request a sparse fieldset and an included relationship, the relationship must be in the list of fields.

### Including related resources

The `render_resource` and `render_resources` methods accept an `include` parameter to request that specific relationships be rendered under the document's **included** member.

```ruby
> SimpleJsonapi.render_resource(order, include: "customer,products")
# or
> SimpleJsonapi.render_resource(order, include: ["customer", "products"])
```

Serializers can allow the client to request related resources sorted in a specific order via the `sort_related` parameter. The sort fields are exposed as an instance variable, `@sort`, which is an array of `SortFieldSpec` objects.

```ruby
> SimpleJsonapi.render_resource(order,
    include: "products",
    sort_related: { products: "-name,id" }
)

class OrderSerializer < SimpleJsonapi::Serializer
  has_many :products do
    data do |order|
      # @sort = [ <SortFieldSpec field=name order=desc>, <SortFieldSpec field=id order=asc> ]
      sort_options = @sort.inject({}) do |hash,spec|
        hash[spec.field] = spec.order
      end
      order.products.order(sort_options)
    end
  end
end
```

### Document links and meta information

**Links** and **meta** information can be added to the document root by passing parameters to `render_resource` or `render_resources`. These parameters must be hashes and are passed through to the rendered document verbatim.

```ruby
> SimpleJsonapi.render_resources(orders,
    links: {
      self: "https://example.com/orders"
    },
    meta: {
      generated_at: Time.now
    })
```

### Custom methods and extra context

Attributes, relationships, if/unless options, links, meta information, and all other definitions that accept proc evaluate those procs in the context of the serializer instance. This means that any methods defined in the serializer class are also available to the procs.

It is also possible to pass in additional variables at render time via the `extras` parameter. Any extra values appear as instance variables on the serializer when the procs are called.

```ruby
class UserSerializer < SimpleJsonapi::Serializer
  attribute :ssn, if: { @current_user.is_an_admin? }
  relationship :orders do
    data { |user| get_orders_for_user(user) }
  end

  def get_orders_for_user(user)
    ...
  end
end

> SimpleJsonapi.render_resources(orders, extras: { current_user: user })
```

## How it works

There are two primary concepts in SimpleJsonapi: serializer definitions and renderer nodes.

Oddly enough, the serializer class is **not** the entry point for serializing a document. That's because a document's **data** member may be a collection of resources of different types, each of which may require a different serializer.

### Serializer definitions

The definitions for a serializer are listed below.

> _NOTE: The `SimpleJsonapi::` prefix is omitted for brevity._

```
Resource serializer [Serializer]
 └─ resource [Definition::Resource]
     ├─ id [Proc]
     ├─ type [Proc]
     ├─ attributes [Hash]
     │   └─ attribute [Definition::Attribute]
     ├─ relationships [Hash]
     │   └─ relationship [Definition::Relationship]
     │       ├─ related data [Proc]
     │       ├─ links [Hash]
     │       │   └─ link [Definition::ObjectLink]
     │       └─ meta [Hash]
     │           └─ meta member [Definition::ObjectMeta]
     ├─ links [Hash]
     │   └─ link [Definition::ObjectLink]
     └─ meta [Hash]
         └─ meta member [Definition::ObjectMeta]

Error serializer [ErrorSerializer]
 └─ error [Definition::Error]
     ├─ id [Proc]
     ├─ status [Proc]
     ├─ code [Proc]
     ├─ title [Proc]
     ├─ detail [Proc]
     ├─ source [Definition::ErrorSource]
     │   ├─ parameter [Proc]
     │   └─ pointer [Proc]
     ├─ links [Hash]
     │   └─ link [Definition::ObjectLink]
     └─ meta [Hash]
         └─ meta member [Definition::ObjectMeta]
```

### Renderer nodes

The nodes involved in rendering a JSONAPI document are listed below. Entries without a class next to them are rendered by their parent node.

> _NOTE: The `SimpleJsonapi::` prefix is omitted for brevity._

```
Resource document [Node::Document::Singular|Collection|Errors]
 ├─ data [Node::Data::Singular|Collection]
 ├─ resource [Node::Resource::Full]
 │   │  (@serializer is modified here)
 │   ├─ id
 │   ├─ type
 │   ├─ attributes [Node::Attributes]
 │   │   └─ attribute
 │   ├─ relationships [Node::Relationships]
 │   │   └─ relationship [Node::Relationship]
 │   │       ├─ data [Node::RelationshipData::Singular|Collection]
 │   │       │   │  (@include_spec and @serializer_inferrer are modified here)
 │   │       │   ├─ resource linkage [Node::Resource::Linkage]
 │   │       │   │   ├─ id
 │   │       │   │   ├─ type
 │   │       │   │   └─ meta
 │   │       │   │       └─ meta member
 │   │       │   └─ resource (added to `included` node) [Node::Resource::Full]
 │   │       │       └─ (see above for details)
 │   │       ├─ links [Node::ObjectLinks]
 │   │       │   └─ link
 │   │       └─ meta [Node::ObjectMeta]
 │   │           └─ meta member
 │   ├─ links [Node::ObjectLinks]
 │   │   └─ link
 │   └─ meta [Node::ObjectMeta]
 │       └─ meta member
 ├─ included [Node::Included]
 │   └─ (resources may be rendered here by the relationship data nodes)
 ├─ links
 │   └─ link
 └─ meta
     └─ meta member

Errors document [Node::Document::Errors]
 ├─ errors [Node::Errors]
 │   ├─ error [Node::Error]
 │   │   ├─ id
 │   │   ├─ status
 │   │   ├─ code
 │   │   ├─ title
 │   │   ├─ detail
 │   │   └─ source [Node::ErrorSource]
 │   │       ├─ parameter
 │   │       └─ pointer
 │   ├─ links [Node::ObjectLinks]
 │   │   └─ link
 │   └─ meta [Node::ObjectMeta]
 │       └─ meta member
 ├─ links
 └─ meta
```

The following parameters are passed into the top-level document node and through the entire node hierarchy.

* **serializer_inferrer** is a `SerializerInferrer` instance, used to choose a serializer for each resource. The serializer_inferrer may be replaced at each relationship data node if that relationship has a `serializer` parameter.
* **serializer** is a Serializer instance, used when rendering a resource and its child members. The serializer is replaced at each resource node.
* **include** is an IncludeSpec instance, created from the `include` parameter. It is replaced at each relationship data node.
* **fields** is a FieldSpec instance, created from the `fields` parameter passed to `serialize_resource(s)` and available throughout the document.
* **sort_related** is a SortSpec instance, created from the `sort_related` parameter and available throughout the document.
* **extras** is the hash passed to `serialize_resource(s)`. Its values are available to every block as instance variables on the serializer.
* **root_node** is a reference to the document node, used to access the **included** node.

## Contributing

Running the tests:

1. Change to the gem's directory
2. Run `bundle install`
3. Run `bundle exec rake test`

## Release Process
Once pull request is merged to master, on latest master:
1. Update CHANGELOG.md. Version: [ major (breaking change: non-backwards
   compatible release) | minor (new features) | patch (bugfixes) ]
2. Update version in lib/global_enforcer/version.rb
3. Release by running `bundle exec rake release`

## License

