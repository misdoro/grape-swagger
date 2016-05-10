require 'representable/json'

RSpec.shared_context 'representable swagger example' do
  before :all do
    module Entities
      class Something < Representable::Decorator
        include Representable::JSON

        class << self
          # Representable doesn't have documentation method, mock this
          def documentation
            {
              id: { type: Integer, desc: 'Identity of Something' },
              text: { type: String, desc: 'Content of something.' },
              links: { type: 'link', is_array: true },
              others: { type: 'text', is_array: false }
            }
          end
        end

        property :id, documentation: { type: Integer, desc: 'Identity of Something' }
        property :text, documentation: { type: String, desc: 'Content of something.' }
        property :links, documentation: { type: 'link', is_array: true }
        property :others, documentation: { type: 'text', is_array: false }
      end

      class EnumValues < Representable::Decorator
        include Representable::JSON

        property :gender, documentation: { type: 'string', desc: 'Content of something.', values: %w(Male Female) }
        property :number, documentation: { type: 'integer', desc: 'Content of something.', values: [1, 2] }
      end

      class AliasedThing < Representable::Decorator
        include Representable::JSON

        property :something, as: :post, decorator: Entities::Something, documentation: { type: 'Something', desc: 'Reference to something.' }
      end

      class FourthLevel < Representable::Decorator
        include Representable::JSON

        property :text, documentation: { type: 'string' }
      end

      class ThirdLevel < Representable::Decorator
        include Representable::JSON

        property :parts, decorator: Entities::FourthLevel, documentation: { type: 'FourthLevel' }
      end

      class SecondLevel < Representable::Decorator
        include Representable::JSON

        property :parts, decorator: Entities::ThirdLevel, documentation: { type: 'ThirdLevel' }
      end

      class FirstLevel < Representable::Decorator
        include Representable::JSON

        property :parts, decorator: Entities::SecondLevel, documentation: { type: 'SecondLevel' }
      end

      class QueryInputElement < Representable::Decorator
        include Representable::JSON

        property :key, documentation: {
          type: String, desc: 'Name of parameter', required: true }
        property :value, documentation: {
          type: String, desc: 'Value of parameter', required: true }
      end

      class QueryInput < Representable::Decorator
        include Representable::JSON

        property :elements, decorator: Entities::QueryInputElement, documentation: {
          type: 'QueryInputElement',
          desc: 'Set of configuration',
          param_type: 'body',
          is_array: true,
          required: true
        }
      end

      class ApiError < Representable::Decorator
        include Representable::JSON

        property :code, documentation: { type: Integer, desc: 'status code' }
        property :message, documentation: { type: String, desc: 'error message' }
      end

      class SecondApiError < Representable::Decorator
        include Representable::JSON

        property :code, documentation: { type: Integer }
        property :severity, documentation: { type: String }
        property :message, documentation: { type: String }
      end

      class ResponseItem < Representable::Decorator
        include Representable::JSON

        class << self
          def documentation
            {
              id: { type: Integer },
              name: { type: String }
            }
          end
        end

        property :id, documentation: { type: Integer }
        property :name, documentation: { type: String }
      end

      class OtherItem < Representable::Decorator
        include Representable::JSON

        property :key, documentation: { type: Integer }
        property :symbol, documentation: { type: String }
      end

      class UseResponse < Representable::Decorator
        include Representable::JSON

        class << self
          def documentation
            {
              :description => { type: String },
              '$responses' => { is_array: true }
            }
          end
        end

        property :description, documentation: { type: String }
        property :items, as: '$responses', decorator: Entities::ResponseItem, documentation: { is_array: true }
      end

      class UseItemResponseAsType < Representable::Decorator
        include Representable::JSON

        property :description, documentation: { type: String }
        property :responses, documentation: { type: Entities::ResponseItem, is_array: false }
      end

      class UseAddress < Representable::Decorator
        include Representable::JSON

        property :street, documentation: { type: String, desc: 'street' }
        property :postcode, documentation: { type: String, desc: 'postcode' }
        property :city, documentation: { type: String, desc: 'city' }
        property :country, documentation: { type: String, desc: 'country' }
      end

      class UseNestedWithAddress < Representable::Decorator
        include Representable::JSON

        property :name, documentation: { type: String }
        property :address, decorator: Entities::UseAddress
      end

      class TypedDefinition < Representable::Decorator
        include Representable::JSON

        property :prop_integer,   documentation: { type: Integer, desc: 'prop_integer description' }
        property :prop_long,      documentation: { type: Numeric, desc: 'prop_long description' }
        property :prop_float,     documentation: { type: Float, desc: 'prop_float description' }
        property :prop_double,    documentation: { type: BigDecimal, desc: 'prop_double description' }
        property :prop_string,    documentation: { type: String, desc: 'prop_string description' }
        property :prop_symbol,    documentation: { type: Symbol, desc: 'prop_symbol description' }
        property :prop_date,      documentation: { type: Date, desc: 'prop_date description' }
        property :prop_date_time, documentation: { type: DateTime, desc: 'prop_date_time description' }
        property :prop_time,      documentation: { type: Time, desc: 'prop_time description' }
        property :prop_password,  documentation: { type: 'password', desc: 'prop_password description' }
        property :prop_email,     documentation: { type: 'email', desc: 'prop_email description' }
        property :prop_boolean,   documentation: { type: Virtus::Attribute::Boolean, desc: 'prop_boolean description' }
        property :prop_file,      documentation: { type: File, desc: 'prop_file description' }
        property :prop_json,      documentation: { type: JSON, desc: 'prop_json description' }
      end
    end
  end

  let(:swagger_definitions_models) do
    {
      'ApiError' => { 'type' => 'object', 'properties' => { 'code' => { 'description' => 'status code', 'type' => 'integer', 'format' => 'int32' }, 'message' => { 'description' => 'error message', 'type' => 'string' } } },
      'ResponseItem' => { 'type' => 'object', 'properties' => { 'id' => { 'description' => '', 'type' => 'integer', 'format' => 'int32' }, 'name' => { 'description' => '', 'type' => 'string' } } },
      'UseResponse' => { 'type' => 'object', 'properties' => { 'description' => { 'description' => '', 'type' => 'string' }, 'items' => { 'type' => 'array', 'items' => { '$ref' => '#/definitions/ResponseItem' }, 'description' => '' } } }
    }
  end

  let(:swagger_nested_type) do
    {
      'ApiError' => { 'type' => 'object', 'properties' => { 'code' => { 'description' => 'status code', 'type' => 'integer', 'format' => 'int32' }, 'message' => { 'description' => 'error message', 'type' => 'string' } }, 'description' => 'This returns something' },
      'UseItemResponseAsType' => { 'type' => 'object', 'properties' => { 'description' => { 'description' => '', 'type' => 'string' }, 'responses' => { 'description' => '', 'type' => 'ResponseItem' } }, 'description' => 'This returns something' }
    }
  end

  let(:swagger_entity_as_response_object) do
    {
      'ApiError' => { 'type' => 'object', 'properties' => { 'code' => { 'description' => 'status code', 'type' => 'integer', 'format' => 'int32' }, 'message' => { 'description' => 'error message', 'type' => 'string' } }, 'description' => 'This returns something' },
      'ResponseItem' => { 'type' => 'object', 'properties' => { 'id' => { 'description' => '', 'type' => 'integer', 'format' => 'int32' }, 'name' => { 'description' => '', 'type' => 'string' } } },
      'UseResponse' => { 'type' => 'object', 'properties' => { 'description' => { 'description' => '', 'type' => 'string' }, 'items' => { 'type' => 'array', 'items' => { '$ref' => '#/definitions/ResponseItem' }, 'description' => '' } }, 'description' => 'This returns something' }
    }
  end

  let(:swagger_params_as_response_object) do
    {
      'ApiError' => { 'type' => 'object', 'properties' => { 'code' => { 'description' => 'status code', 'type' => 'integer', 'format' => 'int32' }, 'message' => { 'description' => 'error message', 'type' => 'string' } }, 'description' => 'This returns something' }
    }
  end

  let(:swagger_typed_defintion) do
    {
      'prop_boolean' => { 'description' => 'prop_boolean description', 'type' => 'boolean' },
      'prop_date' => { 'description' => 'prop_date description', 'type' => 'string', 'format' => 'date' },
      'prop_date_time' => { 'description' => 'prop_date_time description', 'type' => 'string', 'format' => 'date-time' },
      'prop_double' => { 'description' => 'prop_double description', 'type' => 'number', 'format' => 'double' },
      'prop_email' => { 'description' => 'prop_email description', 'type' => 'string', 'format' => 'email' },
      'prop_file' => { 'description' => 'prop_file description', 'type' => 'file' },
      'prop_float' => { 'description' => 'prop_float description', 'type' => 'number', 'format' => 'float' },
      'prop_integer' => { 'description' => 'prop_integer description', 'type' => 'integer', 'format' => 'int32' },
      'prop_json' => { 'description' => 'prop_json description', 'type' => 'Representable::JSON' },
      'prop_long' => { 'description' => 'prop_long description', 'type' => 'integer', 'format' => 'int64' },
      'prop_password' => { 'description' => 'prop_password description', 'type' => 'string', 'format' => 'password' },
      'prop_string' => { 'description' => 'prop_string description', 'type' => 'string' },
      'prop_symbol' => { 'description' => 'prop_symbol description', 'type' => 'string' },
      'prop_time' => { 'description' => 'prop_time description', 'type' => 'string', 'format' => 'date-time' }
    }
  end

  let(:swagger_json) do
    {
      'info' => {
        'title' => 'The API title to be displayed on the API homepage.',
        'description' => 'A description of the API.',
        'termsOfServiceUrl' => 'www.The-URL-of-the-terms-and-service.com',
        'contact' => { 'name' => 'Contact name', 'email' => 'Contact@email.com', 'url' => 'Contact URL' },
        'license' => { 'name' => 'The name of the license.', 'url' => 'www.The-URL-of-the-license.org' },
        'version' => '0.0.1'
      },
      'swagger' => '2.0',
      'produces' => ['application/json'],
      'host' => 'example.org',
      'basePath' => '/api',
      'tags' => [
        { 'name' => 'other_thing', 'description' => 'Operations about other_things' },
        { 'name' => 'thing', 'description' => 'Operations about things' },
        { 'name' => 'thing2', 'description' => 'Operations about thing2s' },
        { 'name' => 'dummy', 'description' => 'Operations about dummies' }
      ],
      'paths' => {
        '/v3/other_thing/{elements}' => {
          'get' => {
            'description' => 'nested route inside namespace',
            'produces' => ['application/json'],
            'parameters' => [{ 'in' => 'body', 'name' => 'elements', 'description' => 'Set of configuration', 'type' => 'array', 'items' => { 'type' => 'string' }, 'required' => true }],
            'responses' => { '200' => { 'description' => 'nested route inside namespace', 'schema' => { '$ref' => '#/definitions/QueryInput' } } },
            'tags' => ['other_thing'],
            'operationId' => 'getV3OtherThingElements',
            'x-amazon-apigateway-auth' => { 'type' => 'none' },
            'x-amazon-apigateway-integration' => { 'type' => 'aws', 'uri' => 'foo_bar_uri', 'httpMethod' => 'get' }
          } },
        '/thing' => {
          'get' => {
            'description' => 'This gets Things.',
            'produces' => ['application/json'],
            'parameters' => [
              { 'in' => 'query', 'name' => 'id', 'description' => 'Identity of Something', 'type' => 'integer', 'format' => 'int32', 'required' => false },
              { 'in' => 'query', 'name' => 'text', 'description' => 'Content of something.', 'type' => 'string', 'required' => false },
              { 'in' => 'formData', 'name' => 'links', 'type' => 'array', 'items' => { 'type' => 'link' }, 'required' => false },
              { 'in' => 'query', 'name' => 'others', 'type' => 'text', 'required' => false }
            ],
            'responses' => { '200' => { 'description' => 'This gets Things.' }, '401' => { 'description' => 'Unauthorized', 'schema' => { '$ref' => '#/definitions/ApiError' } } },
            'tags' => ['thing'],
            'operationId' => 'getThing'
          },
          'post' => {
            'description' => 'This creates Thing.',
            'produces' => ['application/json'],
            'consumes' => ['application/json'],
            'parameters' => [
              { 'in' => 'formData', 'name' => 'text', 'description' => 'Content of something.', 'type' => 'string', 'required' => true },
              { 'in' => 'formData', 'name' => 'links', 'type' => 'array', 'items' => { 'type' => 'string' }, 'required' => true }
            ],
            'responses' => { '201' => { 'description' => 'This creates Thing.', 'schema' => { '$ref' => '#/definitions/Something' } }, '422' => { 'description' => 'Unprocessible Entity' } },
            'tags' => ['thing'],
            'operationId' => 'postThing'
          } },
        '/thing/{id}' => {
          'get' => {
            'description' => 'This gets Thing.',
            'produces' => ['application/json'],
            'parameters' => [{ 'in' => 'path', 'name' => 'id', 'type' => 'integer', 'format' => 'int32', 'required' => true }],
            'responses' => { '200' => { 'description' => 'getting a single thing' }, '401' => { 'description' => 'Unauthorized' } },
            'tags' => ['thing'],
            'operationId' => 'getThingId'
          },
          'put' => {
            'description' => 'This updates Thing.',
            'produces' => ['application/json'],
            'consumes' => ['application/json'],
            'parameters' => [
              { 'in' => 'path', 'name' => 'id', 'type' => 'integer', 'format' => 'int32', 'required' => true },
              { 'in' => 'formData', 'name' => 'text', 'description' => 'Content of something.', 'type' => 'string', 'required' => false },
              { 'in' => 'formData', 'name' => 'links', 'type' => 'array', 'items' => { 'type' => 'string' }, 'required' => false }
            ],
            'responses' => { '200' => { 'description' => 'This updates Thing.', 'schema' => { '$ref' => '#/definitions/Something' } } },
            'tags' => ['thing'],
            'operationId' => 'putThingId'
          },
          'delete' => {
            'description' => 'This deletes Thing.',
            'produces' => ['application/json'],
            'parameters' => [{ 'in' => 'path', 'name' => 'id', 'type' => 'integer', 'format' => 'int32', 'required' => true }],
            'responses' => { '200' => { 'description' => 'This deletes Thing.', 'schema' => { '$ref' => '#/definitions/Something' } } },
            'tags' => ['thing'],
            'operationId' => 'deleteThingId'
          } },
        '/thing2' => {
          'get' => {
            'description' => 'This gets Things.',
            'produces' => ['application/json'],
            'responses' => { '200' => { 'description' => 'get Horses', 'schema' => { '$ref' => '#/definitions/Something' } }, '401' => { 'description' => 'HorsesOutError', 'schema' => { '$ref' => '#/definitions/ApiError' } } },
            'tags' => ['thing2'],
            'operationId' => 'getThing2'
          } },
        '/dummy/{id}' => {
          'delete' => {
            'description' => 'dummy route.',
            'produces' => ['application/json'],
            'parameters' => [{ 'in' => 'path', 'name' => 'id', 'type' => 'integer', 'format' => 'int32', 'required' => true }],
            'responses' => { '204' => { 'description' => 'dummy route.' }, '401' => { 'description' => 'Unauthorized' } },
            'tags' => ['dummy'],
            'operationId' => 'deleteDummyId'
          } } },
      'definitions' => {
        'QueryInput' => {
          'type' => 'object',
          'properties' => { 'elements' => { 'type' => 'array', 'items' => { '$ref' => '#/definitions/QueryInputElement' }, 'description' => 'Set of configuration' } },
          'description' => 'nested route inside namespace'
        },
        'QueryInputElement' => {
          'type' => 'object',
          'properties' => { 'key' => { 'type' => 'string', 'description' => 'Name of parameter' }, 'value' => { 'type' => 'string', 'description' => 'Value of parameter' } }
        },
        'ApiError' => {
          'type' => 'object',
          'properties' => { 'code' => { 'type' => 'integer', 'format' => 'int32', 'description' => 'status code' }, 'message' => { 'type' => 'string', 'description' => 'error message' } },
          'description' => 'This gets Things.'
        },
        'Something' => {
          'type' => 'object',
          'properties' => {
            'id' => { 'type' => 'integer', 'format' => 'int32', 'description' => 'Identity of Something' },
            'text' => { 'type' => 'string', 'description' => 'Content of something.' },
            'links' => { 'type' => 'array', 'items' => { 'description' => '', 'type' => 'link' } },
            'others' => { 'description' => '', 'type' => 'text' }
          },
          'description' => 'This gets Things.'
        } } }
  end

  let(:http_verbs) { %w(get post put delete) }
end

def mounted_paths
  %w( /thing /other_thing /dummy )
end
