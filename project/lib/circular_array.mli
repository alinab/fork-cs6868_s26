(** The type of the circular array that holds elements of type 'a t *)
type 'a t = {
    log_size : int;
    (** The size of the array in log 2. The Chase-Lev algorithm chooses not
        to store the actual size of the array - instead an integer (n) is
        used to store the exponent for computing the size (2 ^ n) of the \
        circular array. When the array needs to be grown dynamically, the
        new size is easily calculated by adding 1 to log_size;i shrinking it
        subtracting 1 from making the calculations simple and symmetric
        *)
    segment : 'a option array;
    (** segment is the actual/physical array that implements the abstract
       CircularArray. It is a historical artifact from previous papers on
       the topic, where "segments" referred to a linked list array
       segments (pieces). In the Chase-Lev algorithm there is just one array
       that is used to implement the dynamic, circular array.
       *)
}

(** [create log_size] creates a circular array with size = 2 ^ log_size.
    Each array element is initialized to None. *)
val create : int -> 'a t

(** [size array] calculates the size of the given array by using its
    log_size paramenter *)
val size : 'a t -> int

(** [get_item array idx] gets the item at idx. Indexing is cyclic via the
    use of mod (%): logical index % array size *)
val get_item : 'a t -> int -> 'a

(** [put_item array idx item] puts item at idx. With cyclic indexing using
    modulo (logical index % array size), the index is guaranteed to a value
    between 0 and array size - 1 *)
val put_item : 'a t -> int -> 'a -> unit

(** grow increments the value 'log_size' of the current array by 1 and uses
    this new size to create an array of size double the original. The items
    in the original array are copied to the new array with the top and
    the bottom indexes unchanged.
    The indexes in the new array will likely be different for the copied
    elements but with array indexing always equal to modulo the array size,
    the values of top and bottom indexes indicating the two ends of the
    dequeue remain the same.
 **)
val grow : 'a t -> bottom:int -> top:int -> 'a t

(** shrink is the dual of grow and decrements the value of 'log_size' of
    the current array by 1, then uses this new size to create an array
    shrunk to the new size *)
val shrink : 'a t -> bottom:int -> top:int -> 'a t
