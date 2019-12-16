#
# Copyright 2019 - David Suárez <david.sephirot@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fluent/plugin/filter"

module Fluent
  module Plugin
    class AddIfNotExistsFilter < Fluent::Plugin::Filter
        
      Fluent::Plugin.register_filter("add_if_not_exists", self)
      
      config_section :add, param_name: :adds, multi: true do
        desc "The field name to test against"
        config_param :key, :string

        desc "The value to add"
        config_param :value, :string
        
        desc "Evaluate the value as ruby?"
        config_param :evalvalue, :bool, :default => false
        
        desc "test only if blank?"
        config_param :onlyblank, :bool, :default => false
      end

      def filter(tag, time, record)
        unless @adds.empty?
          @adds.each { |add|
            if record.include?(add.key) || add.onlyblank
              if not (add.onlyblank && (not record[add.key].nil?) && record[add.key].empty?)
                next
              end
            end
            
            if add.evalvalue
              record[add.key] = instance_eval("#{add.value}")         
            else
              record[add.key] = add.value
            end
          }
        end

        record
      end
    end
  end
end
