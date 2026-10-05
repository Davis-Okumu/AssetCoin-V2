import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/admin_user_list_model.dart';

class UserFilterBar extends StatefulWidget {
  const UserFilterBar({
    super.key,
    required this.filters,
    required this.onChanged,
    required this.onClear,
    required this.onRefresh,
    this.loading = false,
  });

  final UserListFilters filters;

  final ValueChanged<UserListFilters> onChanged;

  final VoidCallback onClear;

  final VoidCallback onRefresh;

  final bool loading;

  @override
  State<UserFilterBar> createState() => _UserFilterBarState();
}

class _UserFilterBarState extends State<UserFilterBar> {
  late final TextEditingController _searchController;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(
      text: widget.filters.search ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant UserFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final value = widget.filters.search ?? '';

    if (value != _searchController.text) {
      _searchController.text = value;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  // =========================================================
  // SEARCH
  // =========================================================

  void _searchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 450), () {
      widget.onChanged(
        _copyFilters(search: value.trim().isEmpty ? null : value.trim()),
      );
    });
  }

  // =========================================================
  // FILTER COPY
  // =========================================================

  UserListFilters _copyFilters({
    String? search,
    String? accountStatus,
    String? kycStatus,
    String? role,
    String? createdFrom,
    String? createdTo,
    String? sortBy,
    String? sortOrder,
  }) {
    return UserListFilters(
      search: search ?? widget.filters.search,
      accountStatus: accountStatus ?? widget.filters.accountStatus,
      kycStatus: kycStatus ?? widget.filters.kycStatus,
      role: role ?? widget.filters.role,
      createdFrom: createdFrom ?? widget.filters.createdFrom,
      createdTo: createdTo ?? widget.filters.createdTo,
      sortBy: sortBy ?? widget.filters.sortBy,
      sortOrder: sortOrder ?? widget.filters.sortOrder,
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 850;

            final fields = [
              SizedBox(
                width: compact ? double.infinity : 300,
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search name, email, phone or ID',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _debounce?.cancel();
                              _searchController.clear();

                              widget.onChanged(_copyFilters(search: null));

                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                ),
              ),
              _buildAccountStatus(),
              _buildKycStatus(),
              _buildRole(),
              _buildSort(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.loading ? null : widget.onClear,
                    icon: const Icon(Icons.filter_alt_off_outlined),
                    label: const Text('Clear'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: widget.loading ? null : widget.onRefresh,
                    icon: widget.loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                  ),
                ],
              ),
            ];

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < fields.length; i++) ...[
                    fields[i],
                    if (i != fields.length - 1) const SizedBox(height: 12),
                  ],
                ],
              );
            }

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: fields,
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // ACCOUNT STATUS
  // =========================================================

  Widget _buildAccountStatus() {
    return SizedBox(
      width: 170,
      child: DropdownButtonFormField<String>(
        initialValue: widget.filters.accountStatus,
        decoration: const InputDecoration(labelText: 'Account status'),
        items: const [
          DropdownMenuItem(value: 'active', child: Text('Active')),
          DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
          DropdownMenuItem(value: 'deactivated', child: Text('Deactivated')),
        ],
        onChanged: (value) {
          widget.onChanged(_copyFilters(accountStatus: value));
        },
      ),
    );
  }

  // =========================================================
  // KYC STATUS
  // =========================================================

  Widget _buildKycStatus() {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<String>(
        initialValue: widget.filters.kycStatus,
        decoration: const InputDecoration(labelText: 'KYC status'),
        items: const [
          DropdownMenuItem(value: 'pending', child: Text('Pending')),
          DropdownMenuItem(value: 'verified', child: Text('Verified')),
          DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
        ],
        onChanged: (value) {
          widget.onChanged(_copyFilters(kycStatus: value));
        },
      ),
    );
  }

  // =========================================================
  // ROLE
  // =========================================================

  Widget _buildRole() {
    return SizedBox(
      width: 170,
      child: DropdownButtonFormField<String>(
        initialValue: widget.filters.role,
        decoration: const InputDecoration(labelText: 'Role'),
        items: const [
          DropdownMenuItem(value: 'user', child: Text('Customer')),
          DropdownMenuItem(value: 'admin', child: Text('Admin')),
        ],
        onChanged: (value) {
          widget.onChanged(_copyFilters(role: value));
        },
      ),
    );
  }

  // =========================================================
  // SORT
  // =========================================================

  Widget _buildSort() {
    return SizedBox(
      width: 170,
      child: DropdownButtonFormField<String>(
        initialValue: widget.filters.sortBy ?? 'createdAt',
        decoration: const InputDecoration(labelText: 'Sort by'),
        items: const [
          DropdownMenuItem(value: 'createdAt', child: Text('Created')),
          DropdownMenuItem(value: 'firstName', child: Text('First name')),
          DropdownMenuItem(value: 'lastName', child: Text('Last name')),
          DropdownMenuItem(value: 'email', child: Text('Email')),
          DropdownMenuItem(
            value: 'accountStatus',
            child: Text('Account status'),
          ),
          DropdownMenuItem(value: 'kycStatus', child: Text('KYC status')),
          DropdownMenuItem(value: 'lastLoginAt', child: Text('Last login')),
        ],
        onChanged: (value) {
          if (value == null) {
            return;
          }

          widget.onChanged(_copyFilters(sortBy: value));
        },
      ),
    );
  }
}
