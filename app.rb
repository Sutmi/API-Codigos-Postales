Cuba.define do
  on options do
  res.headers['Access-Control-Allow-Origin'] = '*'
  res.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
  res.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
  res.write ''
end

  on get do
    on root do
      res.write '<p>Danos un código postal y te regresamos la colonia, municipio y estado.
                 <p>Más información en <a href="https://rapidapi.com/acrogenesis-llc-api/api/mexico-zip-codes">https://rapidapi.com/acrogenesis-llc-api/api/mexico-zip-codes</a></p>'
    end

    on 'codigo_postal/:codigo_postal' do |codigo_postal|
      res.headers['Cache-Control'] = 'max-age=525600, public'
      res.headers['Access-Control-Allow-Origin'] = '*'
      res.write Oj.dump(PostalCode.where(codigo_postal:)
        .as_json(except: :id), mode: :object)
    end

    on 'buscar', param('q') do |query|
      res.headers['Cache-Control'] = 'max-age=525600, public'
      res.headers['Access-Control-Allow-Origin'] = '*'
      res.write Oj.dump(PostalCode.select('DISTINCT codigo_postal')
        .where('codigo_postal LIKE :prefix', prefix: "#{query}%")
        .order('codigo_postal ASC')
        .as_json(except: :id), mode: :object)
    end

    on 'v2/codigo_postal/:codigo_postal' do |codigo_postal|
      res.headers['Cache-Control'] = 'max-age=525600, public'
      res.headers['Access-Control-Allow-Origin'] = '*'
      res.write PostalCodes.fetch_locations(codigo_postal)
    end

    on 'v2/buscar', param('codigo_postal') do |codigo_postal|
      res.headers['Cache-Control'] = 'max-age=525600, public'
      res.headers['Access-Control-Allow-Origin'] = '*'
      limit = req.params['limit']&.to_i
      res.write PostalCodes.fetch_codes(codigo_postal, limit)
    end

    on 'v2/buscar_por_ubicacion', param('estado'), param('municipio') do |estado, municipio|
      res.headers['Cache-Control'] = 'max-age=525600, public'
      res.headers['Access-Control-Allow-Origin'] = '*'
      colonia = req.params['colonia'] # Optional parameter
      limit = req.params['limit']&.to_i
      res.write PostalCodes.fetch_by_location(estado, municipio, colonia, limit)
    end
  end
end
