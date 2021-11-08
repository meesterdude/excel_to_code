class NamedReferences
  
  attr_accessor :named_references, :table_data
  
  def initialize(refs, tables = {})
    @named_references = refs
    @table_data = tables
    @deepCopyCache = {}
  end

  # bookmark
  def reference_for(sheet,named_reference)
    sheet = sheet.downcase
    named_reference = named_reference.downcase.to_sym
    ref = @named_references[[sheet, named_reference]] ||
    @named_references[named_reference] ||
    @table_data[named_reference] ||
    [:error, :"#NAME?"]
    return @deepCopyCache[ref] if @deepCopyCache.key?(ref)
    copy = deep_copy(ref)
    @deepCopyCache[ref] = copy
    return copy
  end

  def deep_copy(ast)
    return ast if ast.is_a?(Symbol)
    return ast if ast.is_a?(Numeric)
    return ast.dup unless ast.is_a?(Array)
    ast.map do |a|
      deep_copy(a)
    end
  end

  
end

class ReplaceNamedReferencesAst
  
  attr_accessor :named_references, :default_sheet_name, :table_data
  
  def initialize(named_references, default_sheet_name = nil, table_data = {})
    @named_references, @default_sheet_name, @table_data = named_references, default_sheet_name, table_data
    @named_references = NamedReferences.new(@named_references, @table_data) unless @named_references.is_a?(NamedReferences)
  end
  
  def map(ast)
    return ast unless ast.is_a?(Array)
    case ast[0]
    when :sheet_reference; sheet_reference(ast)
    when :named_reference; named_reference(ast)
    end
    ast.each { |a| map(a) }
    ast
  end
  
  # Format [:sheet_reference, sheet,  reference]
  def sheet_reference(ast)
    reference = ast[2]
    return unless reference.first == :named_reference
    sheet = ast[1]
    ast.replace(named_references.reference_for(sheet, reference.last))
  end
  
  # Format [:named_reference, name]
  # bookmark
  # rj: had to modify this as it was not picking up bools, and was converting them 
  # into [:error, :"#NAME?"] in reference_for above
  def named_reference(ast)
    if ast[1] == "true"
      ast.replace([:boolean_true])
    elsif ast[1] == "false"
      ast.replace([:boolean_false])
    else
      ast.replace(named_references.reference_for(default_sheet_name, ast[1]))
    end
  end
  
end
  

class ReplaceNamedReferences
  
  attr_accessor :sheet_name, :named_references
  
  def self.replace(*args)
    self.new.replace(*args)
  end
  
  # Rewrites ast with named references
  def replace(values,output)
    named_references = NamedReferences.new(@named_references)
    rewriter = ReplaceNamedReferencesAst.new(named_references,sheet_name)
    values.each_line do |line|
      # Looks to match shared string lines
      if line =~ /\[:named_reference/
        cols = line.split("\t")
        ast = cols.pop
        output.puts "#{cols.join("\t")}\t#{rewriter.map(eval(ast)).inspect}"
      else
        output.puts line
      end
    end
  end
end
