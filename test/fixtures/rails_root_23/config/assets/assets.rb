Rails.application.expansions.register do
  expansion :defaults, :type => :js do
   _'bas/bar'
   _'bar/bas'
  end

  js do
    expansion :bas do
     _'bas/bar'
     _'bar/bas'
    end
  end

  css do
    expansion :bas do
     _'bas/bar'
     _'bar/bas'
    end
  end

  # for ExpansionsTest#asset_test_7
  expansion :jazz do
    js do
     _'bas/bar'
     _'bar/bas'
    end

    css do
     _'bas/bar'
     _'bar/bas'
    end
  end

  # for ExpansionsTest#asset_test_8
  group :development do
    expansion :dev do
      asset 'bas/bar', :type => :js
      asset 'bas/bar', :type => :css
    end
  end

  group :development do
    expansion :dev2 do
      js do
       _'bas/bar'
       _'bar/bas'
      end
    end
  end

  expansion :envs do
    group :development do
      a 'bar/bas', :type => :css
      js do
       _'bar/bas'
      end
    end
  end

  expansion :envs2, :type => :js do
    group :development do
     _'bas/bar'
     _'bar/bas'
    end
  end

  expansion :basfoo do
   _'bas/bar.js'
   _'bar/bas.js'
  end
end
