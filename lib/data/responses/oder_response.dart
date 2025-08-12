class AddressResponse {
  final List<AddressModel>? addresses;

  AddressResponse({this.addresses});

  factory AddressResponse.fromJson(List<dynamic> json) =>
      AddressResponse(addresses: List<AddressModel>.from(json.map((x) => AddressModel.fromJson(x))));
}

class AddressModel {
  final String? addressId;
  final String? addressLine;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? country;

  AddressModel({this.addressId, this.addressLine, this.city, this.province, this.postalCode, this.country});

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    addressId: json["addressId"],
    addressLine: json["addressLine"],
    city: json["city"],
    province: json["province"],
    postalCode: json["postalCode"],
    country: json["country"],
  );

  Map<String, dynamic> toJson() => {
    "addressId": addressId,
    "addressLine": addressLine,
    "city": city,
    "province": province,
    "postalCode": postalCode,
    "country": country,
  };
}
