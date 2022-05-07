//-----------------------------------------------------
// Design Name : SRAM
// File Name   : asynch_saram.v
// Function    : Asynchronous read write RAM 
// Coder       : 
//-----------------------------------------------------
module SRAM (
address     , // Address Input
data        , // Data bi-directional
cs          , // Chip Select
we          , // Write Enable/Read Enable
oe            // Output Enable
);          
parameter DATA_WIDTH = 16 ;
parameter ADDR_WIDTH = 3 ;
parameter RAM_DEPTH = 1 << ADDR_WIDTH;

//--------------Input Ports----------------------- 
input [ADDR_WIDTH-1:0] address ;
input                                     cs           ;
input                                     we           ;
input                                     oe           ; 

//--------------Inout Ports----------------------- 
inout [DATA_WIDTH-1:0]  data       ;

//--------------Internal variables---------------- 
reg [DATA_WIDTH-1:0]   data_out ;
reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1];

//--------------Code Starts Here------------------ 

// Tri-State Buffer control 
// output : When we = 0, oe = 1, cs = 1
assign data = (cs && oe && !we) ? data_out : 16'bz; 

// Memory Write Block 
// Write Operation : When we = 1, cs = 1
always @ (address or data or cs or we)
begin : MEM_WRITE
   if ( cs && we ) begin
       mem[address] = data;
   end
end

// Memory Read Block 
// Read Operation : When we = 0, oe = 1, cs = 1
always @ (address or cs or we or oe)
begin : MEM_READ
    if (cs && !we && oe)  begin
         data_out = mem[address];
    end
end

endmodule // End of Module ram_sp_ar_aw
