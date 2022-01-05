class Position
{
    Position(this.x,this.y);
    Position.fromString(String val) {
      x = int.parse(val.split(' ')[0]);
      y = int.parse(val.split(' ')[1]);
     }
    
    @override
    bool operator== (other)
    {
        if(other is! Position)
        {
            return false;
        }
        return other.x == x && other.y == y;
    }
    @override
    String toString()
    {
        return x.toString() + " " + y.toString();
    }
    @override
    int get hashCode => x.hashCode^y.hashCode;
    var x;
    var y;
}