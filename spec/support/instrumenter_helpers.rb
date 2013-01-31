module InstrumenterHelpers
  def setup_memory_instrumenter
    require 'toy/instrumenters/memory'
    Toy.instrumenter = Toy::Instrumenters::Memory.new
  end

  def clear_instrumenter
    Toy.instrumenter = nil
  end

  def instrumenter
    Toy.instrumenter
  end
end
