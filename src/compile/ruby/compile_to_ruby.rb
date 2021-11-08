require_relative 'map_formulae_to_ruby'

class CompileToRuby
  
  attr_accessor :settable
  attr_accessor :worksheet
  attr_accessor :defaults
  
  def self.rewrite(*args)
    self.new.rewrite(*args)
  end
  
  # bookmark
  def rewrite(input, sheet_names, output)
    self.settable ||= lambda { |ref| false }
    self.defaults ||= []
    mapper = MapFormulaeToRuby.new
    mapper.sheet_names = sheet_names
    output.puts ""
    input.each do |ref, ast|
      begin
        worksheet = ref.first.to_s
        cell = ref.last
        mapper.worksheet = worksheet
        worksheet_c_name = mapper.sheet_names[worksheet] || worksheet.to_s
        name = worksheet_c_name.length > 0 ? "#{worksheet_c_name}_#{cell.downcase}" : cell.downcase
        if settable.call(ref)
          output.puts "  define_method(:#{name})".ljust(38) + "{ @#{name}.call } # Default: #{mapper.map(ast)}"
          defaults << "    @#{name} = lambda { @#{name}_cache ||= #{mapper.map(ast)} }"  # rj added lambdas 
        else
          output.puts "  define_method(:#{name})".ljust(38) + "{ @#{name}_cache ||= #{mapper.map(ast)} } "
        end
      rescue Exception => e
        puts "Exception at #{ref} => #{ast}"
        raise
      end      
    end
  end
  
end
