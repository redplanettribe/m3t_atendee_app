import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pagination_meta.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class PaginationMeta extends Equatable {
  const PaginationMeta({
    this.page,
    this.pageSize,
    this.total,
    this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);

  final int? page;
  final int? pageSize;
  final int? total;
  final int? totalPages;

  PaginationMeta copyWith({
    int? page,
    int? pageSize,
    int? total,
    int? totalPages,
  }) {
    return PaginationMeta(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);

  @override
  List<Object?> get props => [page, pageSize, total, totalPages];
}
