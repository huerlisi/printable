# Printable
module Printable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    # In the controller there is a new method made available by this plugin:
    # print_action_for(method, options = {}).
    #
    # Use it like this:
    # 
    # class InvoicesController < ApplicationController
    #   print_action_for :shipping_document, :tray => :plain, :media => 'A5'
    #   print_action_for :invoice, :tray => :invoice
    #   print_action_for :reminder, :tray => :invoice
    # 
    #  def shipping_document
    #     [...]
    #   end
    # 
    #   def invoice
    #     [...]
    #   end
    # 
    #   def reminder
    #     [...]
    #   end
    # end
    def print_action_for(method, options = {})
      define_method("print_#{method}") do
        self.send("#{method}")
        cups_host = options[:cups_host] || @printers[:cups_host]
        tray = options[:tray].to_sym || :plain
        device = options[:device] || @printers[:trays][tray]
        media = options[:media] || 'A4'

        # You probably need the pdftops filter from xpdf, not poppler on the cups host
        # In my setup it generated an empty page otherwise
        logger.info("Printing to #{device}")
        page = render_to_pdf(:template => "#{controller_name}/#{method}.html.erb", :layout => 'simple', :media => media)
        paper_copy = Cups::PrintJob::Transient.new(page, device)
        paper_copy.print

        respond_to do |format|
          format.html {}
#          format.js {
#            render :update do |page|
#              page.select('.icon-spinner') do |spinner|
#                spinner.toggleClassName('icon-spinner')
#              end
#            end
#          }
        end
      end
    end
  end
end
