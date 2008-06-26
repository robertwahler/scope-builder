require File.dirname(__FILE__) + '/../spec_helper'

class Product < ActiveRecord::Base
  named_scope :released, :conditions => ['released=?', true]
end

describe ScopeBuilder::Builder do
  before(:each) do
    Product.delete_all
    Product.create!(:name => 'a', :released => true)
    Product.create!(:name => 'b', :released => false)
    Product.create!(:name => 'c', :released => true)
    
    @builder = Product.scope_builder
  end
  
  it "should start with empty proxy options" do
    @builder.proxy_options.should == {}
  end
  
  it "should allow named scopes to be called through it" do
    @builder.released.proxy_options.should == Product.released.proxy_options
  end
  
  it "should remember scope calls" do
    @builder.released
    @builder.proxy_options.should == Product.released.proxy_options
  end
  
  it "should build up scopes" do
    @builder.released.scoped(:limit => 1)
    @builder.scoped(:offset => 1)
    @builder.all.should == Product.released.scoped(:limit => 1, :offset => 1).all
  end
  
  it "should enumerate like an array" do
    products = Product.find(:all)
    @builder.each_with_index do |product, index|
      product.should == products[index]
    end
  end
end
