module Jekyll
    class SimpleGenerator < Generator
      safe true 
      def generate(site)
        puts "SimpleGenerator is running!"
      end
    end
  end
