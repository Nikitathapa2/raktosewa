class HiveTableConstant {
  // Private constructor to prevent instantiation
  HiveTableConstant._();

  static const String dbName = "raktosewa_db";

  //we do the indexing for each table for faster searching and querying

  static const int donorTypeId = 0;
  static const String donorTable = "donor_table";

  static const int organizationTypeId = 1;
  static const String organizationTable = "organization_table";
}
