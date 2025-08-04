export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instanciate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "13.0.4"
  }
  public: {
    Tables: {
      click_payments: {
        Row: {
          amount: number
          billing_id: string | null
          cashbox: string | null
          click_id: string
          client_info: string | null
          created_at: string | null
          id: number
          identifier: string | null
          payment_date: string
          payment_method: string | null
          payment_status: string | null
          service_name: string | null
          source_file_id: number | null
          updated_at: string | null
          version: number | null
        }
        Insert: {
          amount: number
          billing_id?: string | null
          cashbox?: string | null
          click_id: string
          client_info?: string | null
          created_at?: string | null
          id?: number
          identifier?: string | null
          payment_date: string
          payment_method?: string | null
          payment_status?: string | null
          service_name?: string | null
          source_file_id?: number | null
          updated_at?: string | null
          version?: number | null
        }
        Update: {
          amount?: number
          billing_id?: string | null
          cashbox?: string | null
          click_id?: string
          client_info?: string | null
          created_at?: string | null
          id?: number
          identifier?: string | null
          payment_date?: string
          payment_method?: string | null
          payment_status?: string | null
          service_name?: string | null
          source_file_id?: number | null
          updated_at?: string | null
          version?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "click_payments_source_file_id_fkey"
            columns: ["source_file_id"]
            isOneToOne: false
            referencedRelation: "files"
            referencedColumns: ["id"]
          },
        ]
      }
      files: {
        Row: {
          content_hash: string
          detected_delimiter: string | null
          detected_encoding: string | null
          duplicate_of_id: number | null
          error_message: string | null
          error_records: number | null
          file_size: number | null
          file_type: string
          file_url: string | null
          filename: string
          id: number
          matched_records: number | null
          original_name: string
          processed_records: number | null
          processed_sheet: string | null
          processing_finished_at: string | null
          processing_started_at: string | null
          processing_status: string | null
          records_count: number | null
          sheet_names: string[] | null
          similarity_percent: number | null
          uploaded_at: string | null
          uploaded_by: string | null
        }
        Insert: {
          content_hash: string
          detected_delimiter?: string | null
          detected_encoding?: string | null
          duplicate_of_id?: number | null
          error_message?: string | null
          error_records?: number | null
          file_size?: number | null
          file_type: string
          file_url?: string | null
          filename: string
          id?: number
          matched_records?: number | null
          original_name: string
          processed_records?: number | null
          processed_sheet?: string | null
          processing_finished_at?: string | null
          processing_started_at?: string | null
          processing_status?: string | null
          records_count?: number | null
          sheet_names?: string[] | null
          similarity_percent?: number | null
          uploaded_at?: string | null
          uploaded_by?: string | null
        }
        Update: {
          content_hash?: string
          detected_delimiter?: string | null
          detected_encoding?: string | null
          duplicate_of_id?: number | null
          error_message?: string | null
          error_records?: number | null
          file_size?: number | null
          file_type?: string
          file_url?: string | null
          filename?: string
          id?: number
          matched_records?: number | null
          original_name?: string
          processed_records?: number | null
          processed_sheet?: string | null
          processing_finished_at?: string | null
          processing_started_at?: string | null
          processing_status?: string | null
          records_count?: number | null
          sheet_names?: string[] | null
          similarity_percent?: number | null
          uploaded_at?: string | null
          uploaded_by?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "files_duplicate_of_id_fkey"
            columns: ["duplicate_of_id"]
            isOneToOne: false
            referencedRelation: "files"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "files_uploaded_by_fkey"
            columns: ["uploaded_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["user_id"]
          },
        ]
      }
      fiscal_receipts: {
        Row: {
          card_amount: number | null
          cash_amount: number | null
          cashier: string | null
          created_at: string | null
          customer_info: string | null
          fiscal_module: string | null
          id: number
          operation_amount: number
          operation_datetime: string
          operation_type: string | null
          receipt_number: string
          recipe_number: string | null
          source_file_id: number | null
          trade_point: string | null
          updated_at: string | null
          version: number | null
        }
        Insert: {
          card_amount?: number | null
          cash_amount?: number | null
          cashier?: string | null
          created_at?: string | null
          customer_info?: string | null
          fiscal_module?: string | null
          id?: number
          operation_amount: number
          operation_datetime: string
          operation_type?: string | null
          receipt_number: string
          recipe_number?: string | null
          source_file_id?: number | null
          trade_point?: string | null
          updated_at?: string | null
          version?: number | null
        }
        Update: {
          card_amount?: number | null
          cash_amount?: number | null
          cashier?: string | null
          created_at?: string | null
          customer_info?: string | null
          fiscal_module?: string | null
          id?: number
          operation_amount?: number
          operation_datetime?: string
          operation_type?: string | null
          receipt_number?: string
          recipe_number?: string | null
          source_file_id?: number | null
          trade_point?: string | null
          updated_at?: string | null
          version?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "fiscal_receipts_source_file_id_fkey"
            columns: ["source_file_id"]
            isOneToOne: false
            referencedRelation: "files"
            referencedColumns: ["id"]
          },
        ]
      }
      hardware_orders: {
        Row: {
          address: string | null
          brew_status: string | null
          brewing_time: string | null
          created_at: string | null
          creation_time: string | null
          delivery_time: string | null
          goods_name: string | null
          id: number
          machine_code: string | null
          order_number: string
          order_price: number | null
          order_resource: string | null
          order_type: string | null
          paying_time: string | null
          payment_status: string | null
          reason: string | null
          refund_time: string | null
          source_file_id: number | null
          taste_name: string | null
          updated_at: string | null
          version: number | null
        }
        Insert: {
          address?: string | null
          brew_status?: string | null
          brewing_time?: string | null
          created_at?: string | null
          creation_time?: string | null
          delivery_time?: string | null
          goods_name?: string | null
          id?: number
          machine_code?: string | null
          order_number: string
          order_price?: number | null
          order_resource?: string | null
          order_type?: string | null
          paying_time?: string | null
          payment_status?: string | null
          reason?: string | null
          refund_time?: string | null
          source_file_id?: number | null
          taste_name?: string | null
          updated_at?: string | null
          version?: number | null
        }
        Update: {
          address?: string | null
          brew_status?: string | null
          brewing_time?: string | null
          created_at?: string | null
          creation_time?: string | null
          delivery_time?: string | null
          goods_name?: string | null
          id?: number
          machine_code?: string | null
          order_number?: string
          order_price?: number | null
          order_resource?: string | null
          order_type?: string | null
          paying_time?: string | null
          payment_status?: string | null
          reason?: string | null
          refund_time?: string | null
          source_file_id?: number | null
          taste_name?: string | null
          updated_at?: string | null
          version?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "hardware_orders_source_file_id_fkey"
            columns: ["source_file_id"]
            isOneToOne: false
            referencedRelation: "files"
            referencedColumns: ["id"]
          },
        ]
      }
      order_changes: {
        Row: {
          change_reason: string | null
          change_type: string
          changed_at: string | null
          changed_by: string | null
          confidence_score: number | null
          field_name: string
          id: number
          new_value: string | null
          old_value: string | null
          order_number: string | null
          processing_batch_id: string | null
          record_id: number
          source_file_id: number | null
          table_name: string
          validation_status: string | null
        }
        Insert: {
          change_reason?: string | null
          change_type: string
          changed_at?: string | null
          changed_by?: string | null
          confidence_score?: number | null
          field_name: string
          id?: number
          new_value?: string | null
          old_value?: string | null
          order_number?: string | null
          processing_batch_id?: string | null
          record_id: number
          source_file_id?: number | null
          table_name: string
          validation_status?: string | null
        }
        Update: {
          change_reason?: string | null
          change_type?: string
          changed_at?: string | null
          changed_by?: string | null
          confidence_score?: number | null
          field_name?: string
          id?: number
          new_value?: string | null
          old_value?: string | null
          order_number?: string | null
          processing_batch_id?: string | null
          record_id?: number
          source_file_id?: number | null
          table_name?: string
          validation_status?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "order_changes_changed_by_fkey"
            columns: ["changed_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["user_id"]
          },
          {
            foreignKeyName: "order_changes_source_file_id_fkey"
            columns: ["source_file_id"]
            isOneToOne: false
            referencedRelation: "files"
            referencedColumns: ["id"]
          },
        ]
      }
      order_errors: {
        Row: {
          conflicting_values: Json | null
          description: string
          error_code: string | null
          error_timestamp: string | null
          error_type: string
          id: number
          order_number: string | null
          processing_batch_id: string | null
          resolution_note: string | null
          resolution_status: string | null
          resolved_at: string | null
          resolved_by: string | null
          severity: string | null
          source_file_id: number | null
          source_record_id: number | null
          source_table: string | null
          suggested_resolution: string | null
          target_record_id: number | null
          target_table: string | null
        }
        Insert: {
          conflicting_values?: Json | null
          description: string
          error_code?: string | null
          error_timestamp?: string | null
          error_type: string
          id?: number
          order_number?: string | null
          processing_batch_id?: string | null
          resolution_note?: string | null
          resolution_status?: string | null
          resolved_at?: string | null
          resolved_by?: string | null
          severity?: string | null
          source_file_id?: number | null
          source_record_id?: number | null
          source_table?: string | null
          suggested_resolution?: string | null
          target_record_id?: number | null
          target_table?: string | null
        }
        Update: {
          conflicting_values?: Json | null
          description?: string
          error_code?: string | null
          error_timestamp?: string | null
          error_type?: string
          id?: number
          order_number?: string | null
          processing_batch_id?: string | null
          resolution_note?: string | null
          resolution_status?: string | null
          resolved_at?: string | null
          resolved_by?: string | null
          severity?: string | null
          source_file_id?: number | null
          source_record_id?: number | null
          source_table?: string | null
          suggested_resolution?: string | null
          target_record_id?: number | null
          target_table?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "order_errors_resolved_by_fkey"
            columns: ["resolved_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["user_id"]
          },
          {
            foreignKeyName: "order_errors_source_file_id_fkey"
            columns: ["source_file_id"]
            isOneToOne: false
            referencedRelation: "files"
            referencedColumns: ["id"]
          },
        ]
      }
      payme_payments: {
        Row: {
          amount_without_commission: number | null
          bank_receipt_date: string | null
          bank_time: string | null
          cancel_time: string | null
          card_number: string | null
          cash_register_id: string | null
          cashbox_identifier: string | null
          cashbox_name: string | null
          client_commission: number | null
          created_at: string | null
          epos_merchant_id: string | null
          epos_terminal_id: string | null
          external_id: string | null
          fiscal_receipt_id: string | null
          fiscal_sign: string | null
          id: number
          order_number: string | null
          payment_description: string | null
          payment_state: string | null
          payment_system_id: string | null
          payment_time: string | null
          processing_name: string | null
          processing_time: string | null
          provider_name: string | null
          provider_payment_id: string | null
          report_number: number | null
          rrn: string | null
          source_file_id: number | null
          state: string | null
          updated_at: string | null
          version: number | null
        }
        Insert: {
          amount_without_commission?: number | null
          bank_receipt_date?: string | null
          bank_time?: string | null
          cancel_time?: string | null
          card_number?: string | null
          cash_register_id?: string | null
          cashbox_identifier?: string | null
          cashbox_name?: string | null
          client_commission?: number | null
          created_at?: string | null
          epos_merchant_id?: string | null
          epos_terminal_id?: string | null
          external_id?: string | null
          fiscal_receipt_id?: string | null
          fiscal_sign?: string | null
          id?: number
          order_number?: string | null
          payment_description?: string | null
          payment_state?: string | null
          payment_system_id?: string | null
          payment_time?: string | null
          processing_name?: string | null
          processing_time?: string | null
          provider_name?: string | null
          provider_payment_id?: string | null
          report_number?: number | null
          rrn?: string | null
          source_file_id?: number | null
          state?: string | null
          updated_at?: string | null
          version?: number | null
        }
        Update: {
          amount_without_commission?: number | null
          bank_receipt_date?: string | null
          bank_time?: string | null
          cancel_time?: string | null
          card_number?: string | null
          cash_register_id?: string | null
          cashbox_identifier?: string | null
          cashbox_name?: string | null
          client_commission?: number | null
          created_at?: string | null
          epos_merchant_id?: string | null
          epos_terminal_id?: string | null
          external_id?: string | null
          fiscal_receipt_id?: string | null
          fiscal_sign?: string | null
          id?: number
          order_number?: string | null
          payment_description?: string | null
          payment_state?: string | null
          payment_system_id?: string | null
          payment_time?: string | null
          processing_name?: string | null
          processing_time?: string | null
          provider_name?: string | null
          provider_payment_id?: string | null
          report_number?: number | null
          rrn?: string | null
          source_file_id?: number | null
          state?: string | null
          updated_at?: string | null
          version?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "payme_payments_source_file_id_fkey"
            columns: ["source_file_id"]
            isOneToOne: false
            referencedRelation: "files"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          created_at: string
          email: string
          full_name: string | null
          id: string
          role: string
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          email: string
          full_name?: string | null
          id?: string
          role?: string
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          email?: string
          full_name?: string | null
          id?: string
          role?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      sales_reports: {
        Row: {
          accrued_bonus: number | null
          barcode: string | null
          created_at: string | null
          formatted_time: string | null
          goods_id: number | null
          goods_name: string | null
          id: number
          ikpu_code: string | null
          machine_category: string | null
          machine_code: string | null
          marking: string | null
          order_number: string | null
          order_price: number | null
          order_resource: string | null
          payment_type: string | null
          report_id: number | null
          source_file_id: number | null
          time_value: number | null
          updated_at: string | null
          username: string | null
          version: number | null
        }
        Insert: {
          accrued_bonus?: number | null
          barcode?: string | null
          created_at?: string | null
          formatted_time?: string | null
          goods_id?: number | null
          goods_name?: string | null
          id?: number
          ikpu_code?: string | null
          machine_category?: string | null
          machine_code?: string | null
          marking?: string | null
          order_number?: string | null
          order_price?: number | null
          order_resource?: string | null
          payment_type?: string | null
          report_id?: number | null
          source_file_id?: number | null
          time_value?: number | null
          updated_at?: string | null
          username?: string | null
          version?: number | null
        }
        Update: {
          accrued_bonus?: number | null
          barcode?: string | null
          created_at?: string | null
          formatted_time?: string | null
          goods_id?: number | null
          goods_name?: string | null
          id?: number
          ikpu_code?: string | null
          machine_category?: string | null
          machine_code?: string | null
          marking?: string | null
          order_number?: string | null
          order_price?: number | null
          order_resource?: string | null
          payment_type?: string | null
          report_id?: number | null
          source_file_id?: number | null
          time_value?: number | null
          updated_at?: string | null
          username?: string | null
          version?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "sales_reports_source_file_id_fkey"
            columns: ["source_file_id"]
            isOneToOne: false
            referencedRelation: "files"
            referencedColumns: ["id"]
          },
        ]
      }
      unified_orders: {
        Row: {
          address: string | null
          brew_status: string | null
          brewing_time: string | null
          click_amount: number | null
          click_billing_id: string | null
          click_cashbox: string | null
          click_client_info: string | null
          click_id: string | null
          click_identifier: string | null
          click_payment_date: string | null
          click_payment_method: string | null
          click_payment_status: string | null
          click_service_name: string | null
          created_at: string | null
          creation_time: string | null
          delivery_time: string | null
          fiscal_card_amount: number | null
          fiscal_cash_amount: number | null
          fiscal_cashier: string | null
          fiscal_customer_info: string | null
          fiscal_module: string | null
          fiscal_operation_amount: number | null
          fiscal_operation_datetime: string | null
          fiscal_operation_type: string | null
          fiscal_receipt_number: string | null
          fiscal_recipe_number: string | null
          fiscal_trade_point: string | null
          goods_name: string | null
          id: number
          is_temporary: boolean | null
          last_matched_at: string | null
          machine_code: string | null
          match_score: number | null
          order_number: string
          order_price: number | null
          order_resource: string | null
          order_type: string | null
          paying_time: string | null
          payme_amount_without_commission: number | null
          payme_card_number: string | null
          payme_cashbox_name: string | null
          payme_client_commission: number | null
          payme_fiscal_receipt_id: string | null
          payme_order_number: string | null
          payme_payment_state: string | null
          payme_payment_system_id: string | null
          payme_payment_time: string | null
          payme_processing_name: string | null
          payme_provider_name: string | null
          payme_provider_payment_id: string | null
          payme_rrn: string | null
          payment_status: string | null
          reason: string | null
          refund_time: string | null
          source_files: string[] | null
          taste_name: string | null
          updated_at: string | null
          uzum_amount: number | null
          uzum_card_number: string | null
          uzum_card_type: string | null
          uzum_commission: number | null
          uzum_merchant_id: string | null
          uzum_parsed_datetime: string | null
          uzum_receipt_id: string | null
          uzum_service_name: string | null
          uzum_status: string | null
          vhr_accrued_bonus: number | null
          vhr_barcode: string | null
          vhr_id: number | null
          vhr_ikpu_code: string | null
          vhr_machine_category: string | null
          vhr_marking: string | null
          vhr_payment_type: string | null
          vhr_time: string | null
          vhr_username: string | null
        }
        Insert: {
          address?: string | null
          brew_status?: string | null
          brewing_time?: string | null
          click_amount?: number | null
          click_billing_id?: string | null
          click_cashbox?: string | null
          click_client_info?: string | null
          click_id?: string | null
          click_identifier?: string | null
          click_payment_date?: string | null
          click_payment_method?: string | null
          click_payment_status?: string | null
          click_service_name?: string | null
          created_at?: string | null
          creation_time?: string | null
          delivery_time?: string | null
          fiscal_card_amount?: number | null
          fiscal_cash_amount?: number | null
          fiscal_cashier?: string | null
          fiscal_customer_info?: string | null
          fiscal_module?: string | null
          fiscal_operation_amount?: number | null
          fiscal_operation_datetime?: string | null
          fiscal_operation_type?: string | null
          fiscal_receipt_number?: string | null
          fiscal_recipe_number?: string | null
          fiscal_trade_point?: string | null
          goods_name?: string | null
          id?: number
          is_temporary?: boolean | null
          last_matched_at?: string | null
          machine_code?: string | null
          match_score?: number | null
          order_number: string
          order_price?: number | null
          order_resource?: string | null
          order_type?: string | null
          paying_time?: string | null
          payme_amount_without_commission?: number | null
          payme_card_number?: string | null
          payme_cashbox_name?: string | null
          payme_client_commission?: number | null
          payme_fiscal_receipt_id?: string | null
          payme_order_number?: string | null
          payme_payment_state?: string | null
          payme_payment_system_id?: string | null
          payme_payment_time?: string | null
          payme_processing_name?: string | null
          payme_provider_name?: string | null
          payme_provider_payment_id?: string | null
          payme_rrn?: string | null
          payment_status?: string | null
          reason?: string | null
          refund_time?: string | null
          source_files?: string[] | null
          taste_name?: string | null
          updated_at?: string | null
          uzum_amount?: number | null
          uzum_card_number?: string | null
          uzum_card_type?: string | null
          uzum_commission?: number | null
          uzum_merchant_id?: string | null
          uzum_parsed_datetime?: string | null
          uzum_receipt_id?: string | null
          uzum_service_name?: string | null
          uzum_status?: string | null
          vhr_accrued_bonus?: number | null
          vhr_barcode?: string | null
          vhr_id?: number | null
          vhr_ikpu_code?: string | null
          vhr_machine_category?: string | null
          vhr_marking?: string | null
          vhr_payment_type?: string | null
          vhr_time?: string | null
          vhr_username?: string | null
        }
        Update: {
          address?: string | null
          brew_status?: string | null
          brewing_time?: string | null
          click_amount?: number | null
          click_billing_id?: string | null
          click_cashbox?: string | null
          click_client_info?: string | null
          click_id?: string | null
          click_identifier?: string | null
          click_payment_date?: string | null
          click_payment_method?: string | null
          click_payment_status?: string | null
          click_service_name?: string | null
          created_at?: string | null
          creation_time?: string | null
          delivery_time?: string | null
          fiscal_card_amount?: number | null
          fiscal_cash_amount?: number | null
          fiscal_cashier?: string | null
          fiscal_customer_info?: string | null
          fiscal_module?: string | null
          fiscal_operation_amount?: number | null
          fiscal_operation_datetime?: string | null
          fiscal_operation_type?: string | null
          fiscal_receipt_number?: string | null
          fiscal_recipe_number?: string | null
          fiscal_trade_point?: string | null
          goods_name?: string | null
          id?: number
          is_temporary?: boolean | null
          last_matched_at?: string | null
          machine_code?: string | null
          match_score?: number | null
          order_number?: string
          order_price?: number | null
          order_resource?: string | null
          order_type?: string | null
          paying_time?: string | null
          payme_amount_without_commission?: number | null
          payme_card_number?: string | null
          payme_cashbox_name?: string | null
          payme_client_commission?: number | null
          payme_fiscal_receipt_id?: string | null
          payme_order_number?: string | null
          payme_payment_state?: string | null
          payme_payment_system_id?: string | null
          payme_payment_time?: string | null
          payme_processing_name?: string | null
          payme_provider_name?: string | null
          payme_provider_payment_id?: string | null
          payme_rrn?: string | null
          payment_status?: string | null
          reason?: string | null
          refund_time?: string | null
          source_files?: string[] | null
          taste_name?: string | null
          updated_at?: string | null
          uzum_amount?: number | null
          uzum_card_number?: string | null
          uzum_card_type?: string | null
          uzum_commission?: number | null
          uzum_merchant_id?: string | null
          uzum_parsed_datetime?: string | null
          uzum_receipt_id?: string | null
          uzum_service_name?: string | null
          uzum_status?: string | null
          vhr_accrued_bonus?: number | null
          vhr_barcode?: string | null
          vhr_id?: number | null
          vhr_ikpu_code?: string | null
          vhr_machine_category?: string | null
          vhr_marking?: string | null
          vhr_payment_type?: string | null
          vhr_time?: string | null
          vhr_username?: string | null
        }
        Relationships: []
      }
      user_roles: {
        Row: {
          id: string
          role: string
          user_id: string
        }
        Insert: {
          id?: string
          role: string
          user_id: string
        }
        Update: {
          id?: string
          role?: string
          user_id?: string
        }
        Relationships: []
      }
      uzum_payments: {
        Row: {
          amount: number
          card_number: string | null
          card_type: string | null
          commission: number | null
          created_at: string | null
          id: number
          merchant_id: string | null
          parsed_datetime: string | null
          payment_datetime: string | null
          receipt_id: string
          service_name: string
          source_file_id: number | null
          status: string | null
          updated_at: string | null
          version: number | null
        }
        Insert: {
          amount: number
          card_number?: string | null
          card_type?: string | null
          commission?: number | null
          created_at?: string | null
          id?: number
          merchant_id?: string | null
          parsed_datetime?: string | null
          payment_datetime?: string | null
          receipt_id: string
          service_name: string
          source_file_id?: number | null
          status?: string | null
          updated_at?: string | null
          version?: number | null
        }
        Update: {
          amount?: number
          card_number?: string | null
          card_type?: string | null
          commission?: number | null
          created_at?: string | null
          id?: number
          merchant_id?: string | null
          parsed_datetime?: string | null
          payment_datetime?: string | null
          receipt_id?: string
          service_name?: string
          source_file_id?: number | null
          status?: string | null
          updated_at?: string | null
          version?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "uzum_payments_source_file_id_fkey"
            columns: ["source_file_id"]
            isOneToOne: false
            referencedRelation: "files"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      consolidate_partial_records: {
        Args: Record<PropertyKey, never>
        Returns: {
          consolidated_count: number
          operation_details: string
        }[]
      }
      find_partial_matches: {
        Args: {
          p_timestamp: string
          p_amount: number
          p_machine_code?: string
          p_order_number?: string
          p_source_type?: string
        }
        Returns: {
          unified_order_id: number
          match_type: string
          confidence_score: number
          time_difference_seconds: number
          existing_sources: string[]
        }[]
      }
      get_partial_data_analysis: {
        Args: Record<PropertyKey, never>
        Returns: {
          id: number
          order_number: string
          machine_code: string
          order_price: number
          is_temporary: boolean
          match_score: number
          has_hardware: string
          has_sales: string
          has_fiscal: string
          has_payme: string
          has_click: string
          has_uzum: string
          available_sources: string
          creation_time: string
          vhr_time: string
          fiscal_operation_datetime: string
          payme_payment_time: string
          click_payment_date: string
          uzum_parsed_datetime: string
          last_matched_at: string
        }[]
      }
      has_role: {
        Args: { _user_id: string; _role: string }
        Returns: boolean
      }
      upsert_to_unified_orders: {
        Args: {
          p_source_type: string
          p_source_data: Json
          p_source_file_id: number
        }
        Returns: {
          operation_type: string
          unified_order_id: number
          match_info: string
        }[]
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
