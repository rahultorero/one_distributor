class StateModel {
  final int fxdid;
  final String statecode;
  final String fxdname;

  StateModel({required this.fxdid, required this.statecode, required this.fxdname});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      fxdid: json['fxdid'],
      statecode: json['statecode'],
      fxdname: json['fxdname'],
    );
  }
}

class CityModel {
  final int grpid;
  final String grpname;

  CityModel({required this.grpid, required this.grpname});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      grpid: json['grpid'],
      grpname: json['grpname'],
    );
  }
}

class AreaModel {
  final int grpid;
  final String grpname;

  AreaModel({required this.grpid, required this.grpname});

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      grpid: json['grpid'],
      grpname: json['grpname'],
    );
  }
}

class CountryModel {
  final int fxdid;
  final String fxdname;
  final int typeid;

  CountryModel({required this.fxdid, required this.fxdname, required this.typeid});

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      fxdid: json['fxdid'],
      fxdname: json['fxdname'],
      typeid: json['typeid'],
    );
  }
}

class LocationResponse {
  final List<StateModel> states;
  final List<CityModel> cities;
  final List<AreaModel> areas;
  final List<CountryModel> countries;

  LocationResponse({
    required this.states,
    required this.cities,
    required this.areas,
    required this.countries,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    var listState = json['state'] as List;
    var listCity = json['city'] as List;
    var listArea = json['area'] as List;
    var listCountry = json['country'] as List;

    List<StateModel> states = listState.map((i) => StateModel.fromJson(i)).toList();
    List<CityModel> cities = listCity.map((i) => CityModel.fromJson(i)).toList();
    List<AreaModel> areas = listArea.map((i) => AreaModel.fromJson(i)).toList();
    List<CountryModel> countries = listCountry.map((i) => CountryModel.fromJson(i)).toList();

    return LocationResponse(
      states: states,
      cities: cities,
      areas: areas,
      countries: countries,
    );
  }
}
